# devcontainer

Container image for development environments with Nix and Docker CLI.

- Image: `ghcr.io/agynio/devcontainer`
- Architectures: `linux/amd64`, `linux/arm64`

Included:
- Ubuntu latest base
- Nix (single-user, non-daemon)
- Docker CLI from Docker’s apt repository

Usage:
- Pull: `docker pull ghcr.io/agynio/devcontainer:latest`
- Run: `docker run --rm -it ghcr.io/agynio/devcontainer:latest bash`

Notes:
- Nix is initialized via `/etc/profile.d/nix.sh`. In interactive shells, PATH includes Nix.
- Verify tools: `nix --version` and `docker --version`.
