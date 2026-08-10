FROM rust:latest AS builder

# Clonar incluyendo submódulos necesarios para traducciones (ftl)
RUN git clone --depth 1 --recurse-submodules https://github.com/ankitects/anki.git /app \
    && cd /app \
    && cargo build --release -p anki-sync-server

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    fuse3 \
    unzip \
    && curl https://rclone.org/install.sh | bash \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/anki-sync-server /usr/local/bin/

RUN sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf

WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/app/entrypoint.sh"]
