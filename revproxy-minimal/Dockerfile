# syntax=docker/dockerfile:1
# nginx 1.3x with njs only, non-root, on the hardened base. No ModSecurity, headers-more or perl.
# Nothing is compiled; the final image is flattened to one layer.
# Config comes from helm/gitops. Since this runs as gen3, set pid /tmp/nginx.pid and listen on 8080.
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
        "nginx-module-njs-${NGINX_VERSION_GLOB}" && \
    rpm -K /rpms/*.rpm

# Stage 1: runtime
FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION} AS runtime

# Runtime libs first, then the nginx RPMs with --nodeps (otherwise they pull in systemd and
# friends, ~150MB we don't need). nginx -t further down fails the build if a lib is missing.
RUN --mount=type=bind,from=rpms,source=/rpms,target=/rpms,readonly \
    dnf install -y \
        --setopt=install_weak_deps=False \
        --setopt=tsflags=nodocs \
        libxml2 pcre2 libedit && \
    rpm --import /rpms/nginx_signing.key && \
    rpm -K /rpms/nginx-[0-9]*.rpm /rpms/nginx-module-njs-*.rpm && \
    rpm -ivh --nodeps --excludedocs /rpms/nginx-[0-9]*.rpm /rpms/nginx-module-njs-*.rpm && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum /var/lib/dnf/history* /var/log/dnf* /var/log/hawkey.log


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

# Build-time steps below run as root; the final image runs as gen3
RUN \
    # drop the default site and sample config
    rm -rf /etc/nginx/conf.d/default.conf /etc/nginx/*.default /usr/share/nginx/html && \
    # config is root-owned, gen3 can't write it
    chmod -R go-w /etc/nginx && \
    # fail the build if nginx or njs won't load (throwaway config)
    printf '%s\n' \
        'load_module modules/ngx_http_js_module.so;' \
        'events {}' 'http {}' > /tmp/module-test.conf && \
    /usr/sbin/nginx -t -c /tmp/module-test.conf && \
    # logs go to stdout/stderr
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    # gen3 owns what nginx writes at runtime, plus a pid file for /run/nginx.pid
    touch /run/nginx.pid && \
    chown -R gen3:gen3 /var/cache/nginx /var/log/nginx /run/nginx.pid && \
    # strip setuid/setgid (no find here, so a bash glob)
    bash -c 'shopt -s globstar nullglob; for f in /usr/**/*; do if [ -f "$f" ] && [ ! -L "$f" ] && { [ -u "$f" ] || [ -g "$f" ]; }; then echo "clearing setuid/setgid: $f"; chmod a-s "$f"; fi; done'

# The rpm database stays so scanners still work. Keep this as the last RUN.
RUN /usr/sbin/usermod -s /sbin/nologin gen3 && \
    pkgs="" && \
    for p in yum dnf dnf-data python3-dnf python3-hawkey python3-libdnf python3-libcomps python3-gpg \
             python3-rpm python3 python3-libs python3-pip-wheel python3-setuptools-wheel \
             libdnf librepo libsolv libmodulemd libcomps gpgme libassuan \
             curl-minimal libcurl-minimal perl-interpreter perl-libs openssl \
             rpm-sign-libs rpm-build-libs bash; do \
        rpm -q "$p" >/dev/null 2>&1 && pkgs="$pkgs $p"; \
    done && \
    rm -f /usr/sbin/capsh /usr/sbin/getpcaps && \
    echo "removing:$pkgs rpm" && \
    rpm -e --nodeps --noscripts $pkgs rpm && \
    rm -rf /etc/dnf /etc/yum* /var/lib/dnf /var/cache/dnf /usr/lib/python3* /usr/share/doc /usr/share/man && \
    /usr/sbin/nginx -t -c /tmp/module-test.conf && \
    rm -rf /tmp/* /var/tmp/*

# Flatten to one layer so removed packages are really gone
FROM scratch AS final
COPY --from=runtime / /

LABEL name="revproxy-nginx-minimal"

# ENV doesn't carry over from the base, and its PATH has no /usr/sbin
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    PATH="/usr/sbin:/usr/local/bin:/usr/bin:/bin"

# Runs as gen3 (uid 1000) from the base image, so no ports below 1024
USER gen3

EXPOSE 8080
STOPSIGNAL SIGTERM
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
