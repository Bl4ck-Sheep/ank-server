FROM debian:bookworm-slim

# Instalar dependencias del sistema, zstd, fuse3 y rclone
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    zstd \
    fuse3 \
    unzip \
    && curl https://rclone.org/install.sh | bash \
    && rm -rf /var/lib/apt/lists/*

# Descargar la última versión del servidor oficial de Anki para Linux
ENV ANKI_VERSION=24.06.3
RUN curl -L https://github.com/ankitects/anki/releases/download/${ANKI_VERSION}/anki-${ANKI_VERSION}-linux-x86_64-cli.tar.zst -o anki.tar.zst \
    && tar --use-compress-program=unzstd -xvf anki.tar.zst \
    && cp anki-${ANKI_VERSION}-linux-x86_64-cli/anki-sync-server /usr/local/bin/ \
    && rm -rf anki.tar.zst anki-${ANKI_VERSION}-linux-x86_64-cli

# Habilitar FUSE para Rclone
RUN sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf

WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/app/entrypoint.sh"]
