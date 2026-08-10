#!/bin/sh
set -e

# Configurar Rclone desde variables de entorno
mkdir -p ~/.config/rclone

cat <<EOF > ~/.config/rclone/rclone.conf
[r2_raw]
type = s3
provider = Cloudflare
access_key_id = ${R2_ACCESS_KEY_ID}
secret_access_key = ${R2_SECRET_ACCESS_KEY}
endpoint = ${R2_ENDPOINT}
acl = private

[r2_crypt]
type = crypt
remote = r2_raw:${R2_BUCKET}
filename_encryption = standard
directory_name_encryption = true
password = $(rclone obscure "${RCLONE_PASSWORD}")
password2 = $(rclone obscure "${RCLONE_SALT}")
EOF

mkdir -p /data

# Montar el almacenamiento cifrado mediante Rclone en /data
echo "Montando bucket R2 cifrado..."
rclone mount r2_crypt: /data \
    --vfs-cache-mode full \
    --vfs-cache-max-size 2G \
    --allow-other \
    --daemon

sleep 3

# Iniciar Anki Sync Server
echo "Iniciando Anki Sync Server..."
export SYNC_USER1="${ANKI_SYNC_USER}"
export SYNC_PORT=10000
export SYNC_BASE=/data

exec anki-sync-server
