# Use a slim base image
FROM debian:stable-slim

# Install required packages
RUN apt update -y && apt install -y git curl tzdata unzip openssh-client && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Set up Git configuration (optional)
ARG GIT_USER_EMAIL="fcharris+lumecms@email.com"
ARG GIT_USER_NAME="LumeCMS"
RUN git config --global user.email "$GIT_USER_EMAIL" && \
    git config --global user.name "$GIT_USER_NAME"

# Configure SSH
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# Environment configuration
ENV TZ=America/New_York
WORKDIR /app

# Install Deno
RUN curl -fsSL https://deno.land/install.sh | sh
ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

# Copy the local repository into the Docker image
COPY ./ .

# Initialize git repository and pre-cache Deno dependencies
RUN git init && \
    git remote remove origin || true && \
    git remote add origin git@github.com:hirefrank/kidsforcasabuna.git && \
    deno cache ./_cms.serve.ts && \
    deno cache ./_cms.lume.ts

# Inline SSH setup script without base64 decoding
RUN echo '#!/bin/sh\n\
set -ex\n\
echo "Starting setup-ssh.sh script"\n\
if [ -z "$SSH_PRIVATE_KEY" ]; then\n\
    echo "No SSH private key provided. Skipping SSH setup."\n\
    exit 1\n\
fi\n\
mkdir -p /root/.ssh && chmod 700 /root/.ssh\n\
echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_ed25519\n\
chmod 600 /root/.ssh/id_ed25519\n\
echo "Testing SSH connection..."\n\
if ! GIT_SSH_COMMAND="ssh -v -i /root/.ssh/id_ed25519" git ls-remote git@github.com:hirefrank/kidsforcasabuna.git; then\n\
    echo "GitHub SSH connection test failed"\n\
    exit 1\n\
fi\n\
echo "Executing production task..."\n\
exec deno task production' > /usr/local/bin/setup-ssh.sh && chmod +x /usr/local/bin/setup-ssh.sh

# Healthcheck for the container
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000 || exit 1

EXPOSE 8000 3000

# Entrypoint for the container
ENTRYPOINT ["/usr/local/bin/setup-ssh.sh"]
