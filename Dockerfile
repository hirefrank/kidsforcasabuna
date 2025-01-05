FROM debian:stable-slim

RUN apt update -y && apt install git curl tzdata unzip openssh-client -y \
&& rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Set up git config - adding this right after git is installed
RUN echo "[user]\n\
    email = fcharris+lumecms@email.com\n\
    name = LumeCMS" > /root/.gitconfig

# Set up SSH directory with proper permissions
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

# SSH config to avoid host verification issues
RUN echo "Host *\n\
    StrictHostKeyChecking no\n\
    UserKnownHostsFile /dev/null" > /root/.ssh/config

ENV TZ=America/New_York
WORKDIR /app

EXPOSE 8000

RUN curl -fsSL https://deno.land/install.sh | sh

ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

# Copy the local repository into the Docker image
COPY ./ .

# Initialize git repository
RUN git init && \
    git remote add origin git@github.com:hirefrank/kidsforcasabuna.git

RUN deno cache ./_cms.serve.ts
RUN deno cache ./_cms.lume.ts

# Create the setup-ssh script inline
RUN echo '#!/bin/sh\n\
if [ ! -z "$SSH_PRIVATE_KEY" ]; then\n\
    echo "$SSH_PRIVATE_KEY" | tr -d \047\\r\047 > /root/.ssh/id_rsa\n\
    chmod 600 /root/.ssh/id_rsa\n\
    git fetch\n\
fi\n\
\n\
exec deno task production' > /usr/local/bin/setup-ssh.sh && \
    chmod +x /usr/local/bin/setup-ssh.sh

ENTRYPOINT ["/usr/local/bin/setup-ssh.sh"]