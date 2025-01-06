# Use a slim base image
FROM debian:stable-slim

# Arguments
ARG GIT_USER_EMAIL="fcharris+lumecms@email.com"
ARG GIT_USER_NAME="LumeCMS"
ARG GIT_REPO_URL="git@github.com:hirefrank/kidsforcasabuna.git"
ARG TZ="America/New_York"

# Install required packages
RUN apt update -y && apt install -y git curl tzdata unzip openssh-client cron supervisor && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Set up Git configuration
RUN git config --global user.email "$GIT_USER_EMAIL" && \
    git config --global user.name "$GIT_USER_NAME"

# Environment configuration
ENV TZ=$TZ
WORKDIR /app

# Install Deno
RUN curl -fsSL https://deno.land/install.sh | sh
ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

# Copy the local repository into the Docker image
COPY ./ .

# Configure SSH
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# Initialize git repository and pre-cache Deno dependencies
RUN git init && \
    git remote remove origin || true && \
    git remote add origin $GIT_REPO_URL && \
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

# Create supervisor configuration inline
RUN echo "[supervisord]\n\
nodaemon=true\n\
\n\
[program:cron]\n\
command=cron -f\n\
\n\
[program:LumeCMS]\n\
command=/usr/local/bin/setup-ssh.sh\n" > /etc/supervisor/conf.d/supervisord.conf

# Create the CPU monitoring script
RUN script_path="/cron_cpu.sh" && \
    echo '#!/usr/bin/env bash' > $script_path && \
    echo 'CPU_USAGE_THRESHOLD=99' >> $script_path && \
    echo 'CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\\([0-9.]*\\)%* id.*/\\1/" | awk "{printf \\"%.0f\\", 100 - \$1}")' >> $script_path && \
    echo 'if [ "$CPU_USAGE" -gt "$CPU_USAGE_THRESHOLD" ]; then' >> $script_path && \
    echo '  systemctl restart lumecms' >> $script_path && \
    echo '  systemctl restart caddy' >> $script_path && \
    echo 'fi' >> $script_path && \
    chmod +x $script_path

# Setup the cron job to run the script
RUN crontab -l > /tmp/mycron || true && \
    echo "*/5 * * * * /cron_cpu.sh" >> /tmp/mycron && \
    crontab /tmp/mycron && \
    rm /tmp/mycron

# Expose ports
EXPOSE 8000 3000

# Use supervisor to manage processes
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]