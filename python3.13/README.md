# Python 3.13  Image Standard

---

## 1. Hardened Base Image Requirement

To ensure a minimal attack surface and compliance with security standards, all Python application images must now be built from our official hardened Amazon Linux base image supply chain.

### Mandatory Image Supply Chain and Dependencies

The image supply chain now enforces a specific lineage, with each subsequent image depending on the secure one preceding it. Always pull the correct image for your build stage from the central repository: `quay.io/cdis/amazonlinux-base`.

| Image Name                          | Stable Tag          | Pull from (Example)                               | Dependency       | Description                                                                       |
| :---------------------------------- | :------------------ | :------------------------------------------------ | :--------------- | :-------------------------------------------------------------------------------- |
| **Amazon Linux Hardened**           | `hardened`          | `quay.io/cdis/amazonlinux-base:hardened`          | None             | Initial security layer. Includes `gen3` user and sets FIPS policy.                |
| **Python 3.13 Build Base**          | `3.13-buildbase`    | `quay.io/cdis/amazonlinux-base:3.13-buildbase`    | `hardened`       | Installs Python 3.13 environment and tooling.                                     |
| **Python 3.13 App Base (Gunicorn)** | `3.13-pythonbase`   | `quay.io/cdis/amazonlinux-base:3.13-pythonbase`   | `3.13-buildbase` | Base image optimized for Python applications (Gunicorn).                          |
| **Python 3.13 Nginx**               | `3.13-pythonnginx`  | `quay.io/cdis/amazonlinux-base:3.13-pythonnginx`  | `3.13-buildbase` | Base image for serving applications via Nginx reverse proxy.                      |
| **Python 3.13 uv**                  | `3.13-pythonuv`     | `quay.io/cdis/amazonlinux-base:3.13-pythonuv`     | `3.13-buildbase` | Base image for uv-managed applications that serve HTTP directly through an async gateway (ASGI) e.g. FastAPI     |
| **Python 3.13 Poetry**              | `3.13-pythonpoetry` | `quay.io/cdis/amazonlinux-base:3.13-pythonpoetry` | `3.13-buildbase` | Base image for poetry-managed applications that serve HTTP directly through an async gateway (ASGI) e.g. FastAPI |

### Which image should we target?

`3.13-pythonuv`, but that requires the underlying app to:

A) Have migrated from poetry to uv


B) Ideally have migrated from Flask **or** FastAPI w/ deprecated use of Gunicorn -> FastAPI w/ uvicorn only

- This incidentally also removes the argument for nginx in front, b/c if you're FastAPI w/ uvicorn, you're using an async gateway (ASGI),
  which defeats the benefit of the complexity of nginx fronting requests (which was historically a pattern to deal with buffering, etc for _syncronous_ gateways, e.g. WSGI)

If the underlying app is FastAPI, but not using `uv` yet, then use `3.13-pythonpoetry` and make sure you satify B above.

Try to avoid the "nginx in the same container fronting Gunicorn+Uvicorn worker" pattern in `3.13-pythonnginx` if the app is FastAPI - it is deprecated and not recommended or needed.

### Moving a FastAPI service off Gunicorn

If the service is FastAPI (or any ASGI framework), it should run **Uvicorn directly, with one
worker process per container**, and scale with replicas rather than workers
([Official FastAPI deployment docs](https://fastapi.tiangolo.com/deployment/docker/)). The
`gunicorn -k uvicorn.workers.UvicornWorker` pattern predates Uvicorn's own process manager and
`uvicorn.workers` is deprecated upstream.

**This does not initially require changing base images.** Most Gen3 services are on `3.13-pythonnginx` as of AUG 2026, and
the pattern change is three edits, none of them to base image initially.

1. Swap `gunicorn` for `uvicorn` in your dependencies, and delete the `gunicorn.conf.py`.
2. In your startup script, replace the Gunicorn invocation with Uvicorn — and **keep starting
   Nginx if your Service still targets port 80**, in which case bind `8000`:

   ```bash
   exec uvicorn myservice.main:app --host 0.0.0.0 --port 8000 --timeout-graceful-shutdown 90
   ```

   `exec` is required. Without it your shell stays PID 1, never forwards `SIGTERM`, and the
   server is killed outright instead of cleaning up: in-flight requests are cut and FastAPI `lifespan`
   shutdown (closing database pools) never runs.
3. Anything the old Gunicorn config did in a hook — logging setup, OpenTelemetry, Prometheus
   multiprocess cleanup — has to move into application startup. The `child_exit` Prometheus hook
   simply goes away with a single process.

Once that is done and working, switching to `3.13-pythonpoetry` or `3.13-pythonuv` is a nice
cleanup that drops the unused Nginx. It requires moving the Service `targetPort` and both probe
ports off `80` **in the same release** as the image change — an old image under a new chart, or the
reverse, fails its probes and crash-loops.

Two notes on dropping Nginx: an idle Nginx is not free, because `worker_processes auto` sizes it to
the *node's* CPU count rather than the container's limit. And we don't lose the standard security
headers, because Gen3's edge revproxy already sets them.

### FIPS 140-3 Compliance Enablement (for Community/Collaborators)

While CTDS runs Gen3 in a FIPS and FedRAMP compliant manner, this change is designed to ensure our community and collaborators can achieve FIPS compliance seamlessly. The upstream base image now enables FIPS mode via update-crypto-policies --set FIPS. This step drastically limits available cryptographic algorithms to those validated by FIPS 140-3, making all resulting applications FIPS-ready out-of-the-box for your deployment environments.

**Action Required:** Applications relying on standard libraries or external packages that use non-FIPS compliant algorithms must be modified.

| Issue            | Explanation                                                                                          | Required Code Adjustment                                                |
| :--------------- | :--------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------- |
| **Disabled MD5** | MD5 is not FIPS-approved and is disabled by default. Many legacy libraries or protocols may fail when attempting to use MD5 for non-security-critical purposes. | Use `usedforsecurity=False` on MD5 calls for non-security-critical use. |

### Disabled MD5 Fix (For non-security-relevant use only):

If your application uses MD5 for non-security-critical purposes, you must explicitly permit its use by passing `usedforsecurity=False` to the constructor in Python's `hashlib` library.

**Old (Failing in FIPS) vs. New (Compliant):**

| State           | Code                                                   | FIPS Behavior (New Container)                                               |
| :-------------- | :----------------------------------------------------- | :-------------------------------------------------------------------------- |
| **Old/Failing** | `hashlib.md5(data).hexdigest()`                        | **Raises `ValueError`** (`[digital envelope routines] unsupported`)         |
| **New/Fix**     | `hashlib.md5(data, usedforsecurity=False).hexdigest()` | **Succeeds**, as the function bypasses the FIPS check for non-security use. |

**Full Code Context:**

```python
import hashlib

# Data to be hashed (e.g., a file path or non-sensitive metadata)
data_to_hash = b"a_very_long_file_name_001.txt"

# ----------------------------------------------------------------------
# 1. FIND (This will fail with a ValueError in the new FIPS container):
# file_id_failing = hashlib.md5(data_to_hash).hexdigest()

# ----------------------------------------------------------------------
# 2. REPLACE WITH (This is the mandatory fix for non-security use):
# We must explicitly set usedforsecurity=False
# ----------------------------------------------------------------------
file_id_compliant = hashlib.md5(
    data_to_hash, 
    usedforsecurity=False
).hexdigest()

# ----------------------------------------------------------------------
# IMPORTANT: FOR SECURITY use (e.g., passwords), DO NOT USE MD5.
# Replace the algorithm entirely with FIPS-approved SHA256 or SHA3.
# ----------------------------------------------------------------------
password_data = b"user_password_2025"
password_hash_compliant = hashlib.sha256(password_data).hexdigest()
```

---

## 2. User Privilege and Permissions (Mandatory)

Containers **must not run as the root user**. Our hardened base image pre-creates a non-root user that all subsequent layers and the final application entry point must use.

The required user is `gen3` (UID 1000, GID 1000). All application Dockerfiles must switch to this user before defining the entry command.

**Mandatory Dockerfile Snippet:**

```Dockerfile
# Start from the buildbase image (which itself starts from Hardened)
FROM quay.io/cdis/amazonlinux-base:3.13-buildbase

# --- Application Layer ---
# Copy your application files
COPY . /app

# Switch to the mandatory non-root user 
# (user 'gen3' with UID 1000 is created in the base image)
USER gen3

# Set the working directory (must be owned by gen3 user)
WORKDIR /app

# Command to run your application
CMD ["/bin/bash", "-c", "./your_app"]
```

---

## 3. CI/CD Pipeline Consolidation and Tagging

We have consolidated the Python 3.13 image build pipeline into a single GitHub Actions workflow (`python313-build-combined.yaml`). All resultant images are deposited into the single central repository: `quay.io/cdis/amazonlinux-base`.

This strategy simplifies image consumption and ensures consistency across all components.

### Consolidated Repository Tagging

| Application Component  | Build Path                          | Stable Tag(s)                            | Example Tag (Feature Branch) |
| :--------------------- | :---------------------------------- | :--------------------------------------- | :--------------------------- |
| **Core Base**          | python3.13/build_base/Dockerfile    | `3.13-buildbase`                         | `fix-feature-3.13-buildbase` |
| **Gunicorn App**       | python3.13/python_base/Dockerfile   | `3.13-pythonbase`, `latest-pythonbase`   | `featureX-3.13-pythonbase`   |
| **Python 3.13 Nginx**  | python3.13/python_nginx/Dockerfile  | `3.13-pythonnginx`, `latest-pythonnginx` | `hotfix-3.13-pythonnginx`    |
| **Python 3.13 uv**     | python3.13/python_uv/Dockerfile     | `3.13-pythonuv`                          | `dev-3.13-pythonuv`          |
| **Python 3.13 Poetry** | python3.13/python_poetry/Dockerfile | `3.13-pythonpoetry`                      | `dev-3.13-pythonpoetry`      |
| **Feature Branch**     | any path                            | `[branch-name]-3.13-[component]`         | `dev-3.13-pythonbase`        |

---