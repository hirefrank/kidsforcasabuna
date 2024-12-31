FROM debian:stable-slim

RUN apt update -y && apt install git curl tzdata unzip -y \
&& rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ENV TZ=America/New_York
WORKDIR /app

EXPOSE 8000

RUN curl -fsSL https://deno.land/install.sh | sh

ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

COPY ./ .

ENTRYPOINT ["deno", "task", "production"]
