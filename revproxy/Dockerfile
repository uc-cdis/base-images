# syntax=docker/dockerfile:1
# nginx 1.3x with ModSecurity, headers-more, njs and perl on the hardened base.
# Build tools stay in the builder stage; the final image is flattened to one layer.
ARG AZLINUX_BASE_VERSION=hardened
# newest nginx matching this glob wins
ARG NGINX_VERSION_GLOB="1.3*"

# Stage 0: download and verify the nginx RPMs
# (separate stage because a later dnf run would delete them)
FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION} AS rpms

ARG NGINX_VERSION_GLOB

COPY nginx.repo /etc/yum.repos.d/nginx.repo

RUN mkdir /rpms && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key -o /rpms/nginx_signing.key && \
    rpm --import /rpms/nginx_signing.key && \
    dnf install -y --downloadonly --downloaddir=/rpms \
        --setopt=install_weak_deps=False --setopt=tsflags=nodocs \
        "nginx-${NGINX_VERSION_GLOB}" \
        "nginx-module-njs-${NGINX_VERSION_GLOB}" \
        "nginx-module-perl-${NGINX_VERSION_GLOB}" && \
    rpm -K /rpms/*.rpm

# Stage 1: build
FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION} AS builder

ARG MODSECURITY_VERSION=v3.0.13
# Newest release tag only, never master (master once truncated big responses, ModSecurity-nginx #336)
ARG MODSECURITY_NGINX_VERSION_GLOB="v1.0.*"
ARG HEADERS_MORE_VERSION=0.38

# Build tools (not in the final image)
RUN dnf install -y \
        gcc gcc-c++ make automake autoconf libtool flex bison \
        git tar gzip \
        libxml2-devel pcre-devel yajl-devel zlib-devel lmdb-devel \
        --setopt=install_weak_deps=False --setopt=tsflags=nodocs

WORKDIR /usr/src

# libmodsecurity is pinned. Curl and lua are off to keep the attack surface down.
RUN git clone --depth 1 --branch "${MODSECURITY_VERSION}" --single-branch \
        --recurse-submodules --shallow-submodules \
        https://github.com/owasp-modsecurity/ModSecurity.git && \
    cd ModSecurity && \
    ./build.sh && \
    ./configure --without-curl --without-lua --disable-examples && \
    make -j"$(nproc)" && \
    make install && \
    strip --strip-unneeded /usr/local/modsecurity/lib/libmodsecurity.so.3*

RUN CONNECTOR_REPO=https://github.com/owasp-modsecurity/ModSecurity-nginx.git && \
    CONNECTOR_TAG="$(git ls-remote --tags --refs --sort=-v:refname "${CONNECTOR_REPO}" "${MODSECURITY_NGINX_VERSION_GLOB}" \
        | head -n1 | sed 's|.*refs/tags/||')" && \
    test -n "${CONNECTOR_TAG}" && \
    echo "Building ModSecurity-nginx ${CONNECTOR_TAG}" && \
    git clone --depth 1 --branch "${CONNECTOR_TAG}" --single-branch "${CONNECTOR_REPO}" && \
    curl -fsSL "https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz" \
        | tar xz

# Build the modules against the nginx version we downloaded
RUN --mount=type=bind,from=rpms,source=/rpms,target=/rpms,readonly \
    NGINX_VERSION="$(rpm -qp --qf '%{VERSION}' /rpms/nginx-[0-9]*.rpm)" && \
    echo "Building modules for nginx ${NGINX_VERSION}" && \
    curl -fsSL "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" | tar xz && \
    cd "nginx-${NGINX_VERSION}" && \
    ./configure --with-compat \
        --add-dynamic-module=../ModSecurity-nginx \
        --add-dynamic-module=../headers-more-nginx-module-${HEADERS_MORE_VERSION} && \
    make -j"$(nproc)" modules && \
    mkdir -p /out/modules && \
    strip --strip-unneeded objs/*.so && \
    cp objs/*.so /out/modules/

# Stage 2: runtime
FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION} AS runtime

# Runtime libs first, then the nginx RPMs with --nodeps (otherwise they pull in systemd and
# friends, ~150MB we don't need). nginx -t further down fails the build if a lib is missing.
RUN --mount=type=bind,from=rpms,source=/rpms,target=/rpms,readonly \
    dnf install -y \
        --setopt=install_weak_deps=False \
        --setopt=tsflags=nodocs \
        libxml2 pcre pcre2 yajl lmdb-libs libstdc++ libedit perl-libs && \
    rpm --import /rpms/nginx_signing.key && \
    rpm -K /rpms/nginx-[0-9]*.rpm /rpms/nginx-module-njs-*.rpm /rpms/nginx-module-perl-*.rpm && \
    rpm -ivh --nodeps --excludedocs \
        /rpms/nginx-[0-9]*.rpm /rpms/nginx-module-njs-*.rpm /rpms/nginx-module-perl-*.rpm && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum /var/lib/dnf/history* /var/log/dnf* /var/log/hawkey.log

# libmodsecurity and the modules from the builder
COPY --from=builder /usr/local/modsecurity/lib/libmodsecurity.so.3* /usr/local/modsecurity/lib/
COPY --from=builder /out/modules/ /usr/lib64/nginx/modules/
RUN echo /usr/local/modsecurity/lib > /etc/ld.so.conf.d/modsecurity.conf && /usr/sbin/ldconfig


ARG FIPS_PROVIDER_VERSION=3.0.8
ARG FIPS_MODULE_VERSION=3.0.8-d694bfa693b76001
RUN dnf -y swap openssl-fips-provider-latest "openssl-fips-provider-certified-${FIPS_PROVIDER_VERSION}*" \
        --setopt=install_weak_deps=False --setopt=tsflags=nodocs && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum /var/lib/dnf/history* /var/log/dnf* /var/log/hawkey.log && \
    sed -i \
        -e 's|^default = default_sect|fips = fips_sect\nbase = base_sect|' \
        -e 's|^\[default_sect\]|[base_sect]|' \
        -e 's|^\[ evp_properties \]|[ evp_properties ]\ndefault_properties = fips=yes|' \
        /etc/pki/tls/openssl.cnf && \
    printf '\n[fips_sect]\nactivate = 1\ntls1-prf-ems-check = 1\n' >> /etc/pki/tls/openssl.cnf && \
    openssl list -providers | grep -q "${FIPS_MODULE_VERSION}" && \
    ! openssl list -providers | grep -q 'OpenSSL Default Provider' && \
    ! (printf x | openssl md5 >/dev/null 2>&1) && \
    printf x | openssl sha256 >/dev/null

# nginx.conf and friends come from helm/gitops, not baked in here

RUN \
    # drop the default site and sample config
    rm -rf /etc/nginx/conf.d/default.conf /etc/nginx/*.default /usr/share/nginx/html && \
    # config is root-owned, nobody else can write it
    chmod -R go-w /etc/nginx && \
    # fail the build if a module or lib won't load (throwaway config)
    printf '%s\n' \
        'load_module modules/ngx_http_modsecurity_module.so;' \
        'load_module modules/ngx_http_headers_more_filter_module.so;' \
        'load_module modules/ngx_http_js_module.so;' \
        'load_module modules/ngx_http_perl_module.so;' \
        'events {}' 'http {}' > /tmp/module-test.conf && \
    /usr/sbin/nginx -t -c /tmp/module-test.conf && \
    # logs go to stdout/stderr
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    # strip setuid/setgid (no find here, so a bash glob)
    bash -c 'shopt -s globstar nullglob; for f in /usr/**/*; do if [ -f "$f" ] && [ ! -L "$f" ] && { [ -u "$f" ] || [ -g "$f" ]; }; then echo "clearing setuid/setgid: $f"; chmod a-s "$f"; fi; done'

# The rpm database stays so scanners still work. REMOVE_SHELL=true drops bash too;
ARG REMOVE_SHELL=false
RUN /usr/sbin/usermod -s /sbin/nologin gen3 && \
    pkgs="" && \
    for p in yum dnf dnf-data python3-dnf python3-hawkey python3-libdnf python3-libcomps python3-gpg \
             python3-rpm python3 python3-libs python3-pip-wheel python3-setuptools-wheel \
             libdnf librepo libsolv libmodulemd libcomps gpgme libassuan \
             curl-minimal libcurl-minimal perl-interpreter openssl \
             rpm-sign-libs rpm-build-libs; do \
        rpm -q "$p" >/dev/null 2>&1 && pkgs="$pkgs $p"; \
    done && \
    if [ "${REMOVE_SHELL}" = "true" ]; then pkgs="$pkgs bash"; fi && \
    rm -f /usr/sbin/capsh /usr/sbin/getpcaps && \
    echo "removing:$pkgs rpm" && \
    rpm -e --nodeps --noscripts $pkgs rpm && \
    rm -rf /etc/dnf /etc/yum* /var/lib/dnf /var/cache/dnf /usr/lib/python3* /usr/share/doc /usr/share/man && \
    /usr/sbin/nginx -t -c /tmp/module-test.conf && \
    rm -rf /tmp/* /var/tmp/*

# Stage 3: flatten to one layer so removed packages are really gone
FROM scratch AS final
COPY --from=runtime / /

LABEL name="revproxy-nginx"

# ENV doesn't carry over from the base, and its PATH has no /usr/sbin
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    PATH="/usr/sbin:/usr/local/bin:/usr/bin:/bin"

EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
