FROM mcr.microsoft.com/devcontainers/python:3.14-bookworm

# Remove the Yarn apt repository that has an expired GPG key,
# which causes apt-get update to fail during feature installation.
RUN rm -f /etc/apt/sources.list.d/yarn.list \
    && rm -f /usr/share/keyrings/yarn-keyring.gpg \
    && apt-get update

# Pre-create volume mount points with correct ownership so that
# Docker initializes named volumes with vscode user permissions.
RUN mkdir -p /home/vscode/.vscode-server /home/vscode/.claude \
    && chown -R vscode:vscode /home/vscode/.vscode-server /home/vscode/.claude
