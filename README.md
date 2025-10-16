# devcontainer

Container image for development environments with Nix and Docker CLI.

- Image: `ghcr.io/agynio/devcontainer`
- Architectures: `linux/amd64`, `linux/arm64`

Included:
- Ubuntu 24.04 base (pinned)
- Nix via Determinate Systems installer (no init/systemd; sandbox disabled)
- Docker CLI from Docker’s apt repository

Usage:
- Pull: `docker pull ghcr.io/agynio/devcontainer:latest`
- Run: `docker run --rm -it ghcr.io/agynio/devcontainer:latest bash`

Notes:
- Nix is initialized via `/etc/profile.d/nix.sh` which sources the Nix environment; PATH includes Nix bins.
- Docker CLI requires access to a running Docker daemon. For local usage, you may mount the host socket: `-v /var/run/docker.sock:/var/run/docker.sock`.
- Verify tools: `nix --version` and `docker --version`.
