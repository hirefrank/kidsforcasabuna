FROM debian:stable-slim

RUN apt update -y && apt install git curl tzdata unzip -y \
&& rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ENV TZ=America/New_York
WORKDIR /app

EXPOSE 8000
EXPOSE 3000

RUN curl -fsSL https://deno.land/install.sh | sh

ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

COPY ./ .

RUN deno cache ./src/_cms.serve.ts
RUN deno cache ./src/_cms.lume.ts

ENTRYPOINT ["deno", "task", "production"]
