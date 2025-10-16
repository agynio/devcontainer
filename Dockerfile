FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies and Docker CLI (from Docker's official apt repo)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      xz-utils \
      gnupg; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends docker-ce-cli; \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

ENV HOME=/root

# Install Nix using Determinate Systems installer (no init/systemd), sandbox disabled
RUN set -eux; \
    mkdir -p /nix /etc/nix; chmod 0755 /nix; \
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --init none --no-confirm --extra-conf 'sandbox = false'

# Add profile hook to source Nix in shells and verify
RUN printf '. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh\n' > /etc/profile.d/nix.sh


# Ensure PATH includes Nix binaries for non-login shells as well
ENV PATH=/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}

# Ensure PATH includes Nix binaries for non-login shells as well

# Verify installations
RUN bash -lc '. /etc/profile.d/nix.sh && nix --version && docker --version'

# Default shell
SHELL ["/bin/bash", "-lc"]
