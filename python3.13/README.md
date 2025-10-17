# Python 3.13  Image Standard


---

## 1. Hardened Base Image Requirement

To ensure a minimal attack surface and compliance with security standards, all Python application images must now be built from our official hardened Amazon Linux base image supply chain.

### Mandatory Image Supply Chain and Dependencies

The image supply chain now enforces a specific lineage, with each subsequent image depending on the secure one preceding it. Always pull the correct image for your build stage from the central repository: `quay.io/cdis/amazonlinux-base`.

| Image Name                          | Stable Tag          | Pull from (Example)                          | Dependency | Description |
|:------------------------------------| :--- | :--- | :--- | :--- |
| **Amazon Linux Hardened**           | `hardened`          | `quay.io/cdis/amazonlinux-base:hardened`     | None | Initial security layer. Includes `gen3` user and sets FIPS policy. |
| **Python 3.13 Build Base**          | `3.13-buildbase`    | `quay.io/cdis/amazonlinux-base:3.13-buildbase` | `hardened` | Installs Python 3.13 environment and tooling. |
| **Python 3.13 App Base (Gunicorn)** | `3.13-pythonbase` | `quay.io/cdis/amazonlinux-base:3.13-pythonbase` | `3.13-buildbase` | Base image optimized for Python applications (Gunicorn). |
| **Python 3.13 Nginx**               | `3.13-pythonnginx`  | `quay.io/cdis/amazonlinux-base:3.13-pythonnginx` | `3.13-buildbase` | Base image for serving applications via Nginx reverse proxy. |

### FIPS 140-3 Compliance Enablement (for Community/Collaborators)

While CTDS runs Gen3 in a FIPS and FedRAMP compliant manner, this change is designed to ensure our community and collaborators can achieve FIPS compliance seamlessly. The upstream base image now enables FIPS mode via update-crypto-policies --set FIPS. This step drastically limits available cryptographic algorithms to those validated by FIPS 140-3, making all resulting applications FIPS-ready out-of-the-box for your deployment environments.

**Action Required:** Applications relying on standard libraries or external packages that use non-FIPS compliant algorithms must be modified.

| Issue | Explanation | Required Code Adjustment |
| :--- | :--- | :--- |
| **Disabled MD5** | MD5 is not FIPS-approved and is disabled by default. Many legacy libraries or protocols may fail when attempting to use MD5 for non-security-critical purposes. | Use `usedforsecurity=False` on MD5 calls for non-security-critical use. |

### Disabled MD5 Fix (For non-security-relevant use only):

If your application uses MD5 for non-security-critical purposes, you must explicitly permit its use by passing `usedforsecurity=False` to the constructor in Python's `hashlib` library.

**Old (Failing in FIPS) vs. New (Compliant):**

| State | Code | FIPS Behavior (New Container) |
| :--- | :--- | :--- |
| **Old/Failing** | `hashlib.md5(data).hexdigest()` | **Raises `ValueError`** (`[digital envelope routines] unsupported`) |
| **New/Fix** | `hashlib.md5(data, usedforsecurity=False).hexdigest()` | **Succeeds**, as the function bypasses the FIPS check for non-security use. |

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

| Application Component | Build Path                         | Stable Tag(s)                            | Example Tag (Feature Branch) |
|:----------------------|:-----------------------------------|:-----------------------------------------|:-----------------------------|
| **Core Base**         | python3.13/build_base/Dockerfile   | `3.13-buildbase`                         | `fix-feature-3.13-buildbase` |
| **Gunicorn App**      | python3.13/python_base/Dockerfile  | `3.13-pythonbase`, `latest-pythonbase`   | `featureX-3.13-pythonbase`   |
| **Python 3.13 Nginx** | python3.13/python_nginx/Dockerfile | `3.13-pythonnginx`, `latest-pythonnginx` | `hotfix-3.13-pythonnginx`    |
| **Feature Branch**    | any path                           | `[branch-name]-3.13-[component]`         | `dev-3.13-pythonbase`        |

---
