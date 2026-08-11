FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    fuse3 \
    unzip \
    && curl https://rclone.org/install.sh | bash \
    && rm -rf /var/lib/apt/lists/*

# Instalar el servidor oficial mediante el gestor de paquetes de Python
RUN pip install --no-cache-dir anki

# Habilitar FUSE para Rclone
RUN sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf

WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/app/entrypoint.sh"]
