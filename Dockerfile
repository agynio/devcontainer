FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies and Docker CLI (from Docker's official apt repo)
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  xz-utils \
  gnupg \
  zsh; \
  mkdir -p /etc/apt/keyrings; \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list; \
  apt-get update; \
  apt-get install -y --no-install-recommends docker-ce-cli; \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

ENV HOME=/root

# ubuntu:24.04 names no locale, and glibc's C fallback cannot decode UTF-8:
# zsh's line editor renders every byte of a typed accent or Cyrillic letter as
# <ffffffff>. C.UTF-8 is built into glibc 2.39 — no locales package needed.
ENV LANG=C.UTF-8

# Install Nix using Determinate Systems installer (no init/systemd), sandbox disabled
RUN set -eux; \
  mkdir -p /nix /etc/nix; chmod 0755 /nix; \
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --init none --no-confirm --extra-conf 'sandbox = false'

# Add profile hook to source Nix in shells and verify
RUN printf '. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh\n' > /etc/profile.d/nix.sh

# zsh is the login shell; SHELL is what a terminal session execs
ENV SHELL=/usr/bin/zsh
RUN set -eux; \
  chsh -s /usr/bin/zsh root; \
  printf "emulate sh -c 'source /etc/profile'\n" >> /etc/zsh/zprofile; \
  printf '%s\n' \
  'HISTFILE=~/.zsh_history' \
  'HISTSIZE=10000' \
  'SAVEHIST=10000' \
  'setopt hist_ignore_dups inc_append_history' \
  "PROMPT='%n@%m %~ %# '" \
  > /root/.zshrc


# Ensure PATH includes Nix binaries for non-login shells as well
ENV PATH=/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}

# Ensure PATH includes Nix binaries for non-login shells as well

# Verify installations
RUN bash -lc '. /etc/profile.d/nix.sh && nix --version && docker --version'
RUN zsh -lc 'nix --version && docker --version'

# Build-time shell for RUN; the runtime default is SHELL=/usr/bin/zsh above
SHELL ["/bin/bash", "-lc"]

# Default CMD
CMD ["sleep", "infinity"]
