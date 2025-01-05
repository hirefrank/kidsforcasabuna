#!/bin/sh
if [ ! -z "$SSH_PRIVATE_KEY" ]; then
    echo "$SSH_PRIVATE_KEY" | tr -d '\r' > /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
fi

# Your original entrypoint command
exec deno task production