# Use a slim base image
FROM debian:stable-slim

# Arguments
ARG GIT_USER_EMAIL="fcharris+lumecms@email.com"
ARG GIT_USER_NAME="LumeCMS"
ARG GIT_REPO_URL="git@github.com:hirefrank/kidsforcasabuna.git"
ARG TZ="America/New_York"

# Install required packages
RUN apt update -y && apt install -y git curl tzdata unzip openssh-client cron supervisor procps && \
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

# Inline SSH setup script
RUN echo '#!/bin/sh\n\
set -ex\n\
if [ -z "$SSH_PRIVATE_KEY" ]; then\n\
    echo "No SSH private key provided. Proceeding without GitHub access."\n\
else\n\
    mkdir -p /root/.ssh && chmod 700 /root/.ssh\n\
    echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_ed25519\n\
    chmod 600 /root/.ssh/id_ed25519\n\
    echo "Testing SSH connection..."\n\
    GIT_SSH_COMMAND="ssh -v -i /root/.ssh/id_ed25519" git ls-remote git@github.com:hirefrank/kidsforcasabuna.git\n\
fi\n\
exec deno task production' > /usr/local/bin/setup-ssh.sh && chmod +x /usr/local/bin/setup-ssh.sh

# Create supervisor configuration inline
RUN echo "[unix_http_server]\n\
file=/dev/shm/supervisor.sock\n\
chmod=0700\n\
\n\
[supervisord]\n\
nodaemon=true\n\
user=root\n\
\n\
[program:cron]\n\
command=cron -f\n\
priority=1\n\
autostart=true\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stdout_logfile_maxbytes=0\n\
stderr_logfile=/dev/stderr\n\
stderr_logfile_maxbytes=0\n\
\n\
[program:LumeCMS]\n\
priority=10\n\
autostart=true\n\
autorestart=true\n\
command=/usr/local/bin/setup-ssh.sh\n\
stdout_logfile=/var/log/supervisor/LumeCMS.log\n\
stderr_logfile=/var/log/supervisor/LumeCMS_err.log\n\
\n\
[rpcinterface:supervisor]\n\
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface\n\
\n\
[supervisorctl]\n\
serverurl=unix:///dev/shm/supervisor.sock" > /etc/supervisor/conf.d/supervisord.conf


# Create the CPU monitoring script
RUN script_path="/cron_cpu.sh" && \
    echo '#!/usr/bin/env bash' > $script_path && \
    echo 'CPU_USAGE=$(ps -eo pcpu | awk "{sum+=$1} END {print int(sum)}")' >> $script_path && \
    echo 'if [ "$CPU_USAGE" -gt "99" ]; then\n supervisorctl restart LumeCMS\nfi' >> $script_path && \
    chmod +x $script_path

# Setup the cron job to run the script
RUN echo "*/5 * * * * /cron_cpu.sh" | crontab -

# Expose ports
EXPOSE 8000 3000

# Use supervisor to manage processes
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
