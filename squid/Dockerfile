ARG AZLINUX_BASE_VERSION=master
FROM 707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/amazonlinux-base:${AZLINUX_BASE_VERSION}

# Update package lists and install the latest packages
RUN dnf update -y && dnf upgrade -y

# Create a non-root user for Squid with a strong random password
RUN useradd -m -s /bin/bash squid

# Install required packages
RUN dnf install squid -y

# Create Squid configuration directory
RUN mkdir -p /etc/squid

# Basic Squid Configuration (adjust as needed)
RUN echo 'acl safe_ports port 80' >> /etc/squid/squid.conf
RUN echo 'http_access allow safe_ports' >> /etc/squid/squid.conf

# Create cache directory (adjust path if needed)
RUN mkdir -p /var/spool/squid

# Create log directory (adjust path if needed)
RUN mkdir -p /var/log/squid

# Run updates
RUN dnf update -y && dnf upgrade -y

# Set ownership and permissions for Squid directories
RUN chown -R squid:squid /etc/squid /var/spool/squid /var/log/squid

# Expose Squid Ports
EXPOSE 3128/tcp
EXPOSE 3129/tcp
EXPOSE 3130/tcp

# Start Squid service as the squid user
USER squid
CMD ["squid", "-Nyd"]
