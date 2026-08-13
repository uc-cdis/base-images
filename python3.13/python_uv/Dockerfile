ARG AZLINUX_BASE_VERSION=3.13-buildbase
FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION}

LABEL name="python-uv-base"
LABEL version="3.13"

# Base for uv-managed Python apps that serve HTTP themselves, with no in-container Nginx. The app
# binds its own port. Applications resolve their dependencies into /venv from their own uv.lock.

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8

# Track the latest uv release. Downstream services install from a committed uv.lock with
# `--frozen`, so uv does not choose dependency versions and a bump cannot silently change what
# gets installed. The frozen flag is important! A plain `uv sync` re-locks when the lockfile is stale.
#
# IMPORTANT: Using latest uv MAY break apps, if the lock file format changes, but that will fail loudly
# during a build and we can either update the lock file (preferred) or pin a uv version here
# (non-ideal).
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Force uv onto the FIPS-enabled interpreter from the hardened lineage. Without these it will
# happily download its own unvetted CPython build at install time.
ENV UV_NO_MANAGED_PYTHON=true \
    UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/venv

# Non-root by default so a derived image has to opt *in* to root rather than remember to opt out.
USER gen3
