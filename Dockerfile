FROM debian:12-slim AS deps
ARG DEBIAN_FRONTEND=noninteractive

ENV PATH="/root/.cargo/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    curl build-essential \
    && curl https://sh.rustup.rs -sSf | bash -s -- -y \
    && cargo install jwt-cli \
    && ls -al "$HOME/.cargo/bin" \
    && rm -rf /var/lib/apt/lists/*

FROM debian:12-slim
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    yq gh curl git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=deps /root/.cargo/bin/jwt /usr/local/bin/jwt
COPY scripts .

RUN chmod +x entrypoint.sh

CMD ["bash", "entrypoint.sh"]