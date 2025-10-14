ARG AZLINUX_BASE_VERSION=hardened
FROM 707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/amazonlinux-base:${AZLINUX_BASE_VERSION}

LABEL name="python-app-base"
LABEL version="3.13"

# Copy your demo app
COPY ./app /app

# Ensure ownership by gen3 user
RUN chown -R gen3:gen3 /app

WORKDIR /app

# Install dependencies securely & cleanly
RUN python3.13 -m pip install --no-cache-dir --upgrade pip && \
    python3.13 -m pip install --no-cache-dir gunicorn==21.2.0 ddtrace==2.7.6

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8

USER gen3

# Set entrypoint (adjust "app:app" as needed for your code)
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8000"]