FROM debian:12-slim AS deps
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /usr/src/app
ENV PATH="/root/.cargo/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    curl build-essential coreutils \
    && curl https://sh.rustup.rs -sSf | bash -s -- -y \
    && cargo install jwt-cli \
    && ls -al "$HOME/.cargo/bin" \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" \
    && echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

FROM debian:12-slim
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y \
    yq gh curl git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=deps /root/.cargo/bin/jwt /usr/local/bin/jwt
COPY --from=deps /usr/src/app/kubectl /usr/local/bin/kubectl
COPY scripts .

RUN chmod +x entrypoint.sh /usr/local/bin/kubectl

CMD ["bash", "entrypoint.sh"]