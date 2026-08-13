ARG AZLINUX_BASE_VERSION=3.13-buildbase
FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION}

LABEL name="python-poetry-base"
LABEL version="3.13"

# Same serving model as 3.13-pythonuv - the app binds its own port, with no in-container Nginx -
# but for services managed by Poetry. It exists so that moving off the Gunicorn +
# uvicorn.workers.UvicornWorker pattern does not also force a package manager migration.

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8

RUN python3.13 -m pip install --no-cache-dir --upgrade pip && \
    python3.13 -m pip install --no-cache-dir pipx && \
    rm -rf /root/.cache

# Non-root by default so a derived image has to opt *in* to root rather than remember to opt out.
USER gen3

# Track the latest Poetry release. A Poetry bump does not choose dependency versions, and
# an incompatible lock format fails loudly at build time.
#
# Note this is a major ahead of 3.13-pythonnginx, which pins `>=1.7,<2.0`, so moving a service
# from that image to this one is also a Poetry 1.x -> 2.x migration. `poetry install --sync` still
# works but is deprecated in favour of `poetry sync`.
RUN pipx install poetry && rm -rf /home/gen3/.cache/pipx
ENV PATH="/home/gen3/.local/bin:${PATH}"
