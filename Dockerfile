FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies and Docker CLI (from Docker's official apt repo)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      xz-utils \
      gnupg \
      lsb-release; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends docker-ce-cli; \
    rm -rf /var/lib/apt/lists/*

# Install Nix (single-user, non-daemon) and ensure it's sourced via /etc/profile.d/nix.sh
RUN set -eux; \
    curl -fsSL https://nixos.org/nix/install -o /tmp/install-nix.sh; \
    sh /tmp/install-nix.sh --no-daemon; \
    rm -f /tmp/install-nix.sh; \
    mkdir -p /etc/profile.d; \
    printf '%s\n' \
      '# Nix profile setup' \
      'if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then' \
      '  . "$HOME/.nix-profile/etc/profile.d/nix.sh"' \
      'fi' \
      'export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"' \
      > /etc/profile.d/nix.sh

# Ensure PATH includes Nix binaries for non-login shells as well
ENV PATH=/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}

# Verify installations
RUN bash -lc '. /etc/profile.d/nix.sh; nix --version' \
 && docker --version

# Default shell
SHELL ["/bin/bash", "-lc"]

