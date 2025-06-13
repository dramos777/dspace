#!/usr/bin/env bash
#
DOMAIN='test.example.org'
EMAIL=emanuel.ramos@example.org

SCRIPT_FULLNAME=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_BASENAME=$(basename $0)
SCRIPT_DIR_TEST="scripts/$SCRIPT_BASENAME"

echo $SCRIPT_FULLNAME | grep "$SCRIPT_DIR_TEST"
if [ "$?" = 0 ];then
    CERTDIR="$(echo "$SCRIPT_FULLNAME"| sed "s/scripts\/$SCRIPT_BASENAME//g")certs/"
else
    echo "    ALERTA: Se o script estiver fora do diretório padrão pode gerar comportamento indesejado!"
    echo "    Diretório esperado: $PWD/scripts"
    CERTDIR="$(echo "$SCRIPT_FULLNAME"| sed "s/$SCRIPT_BASENAME//g")certs/"
fi

    # Ensure directories exist or create them
LETSENCRYPT_DIR=$CERTDIR
if [ ! -d "$LETSENCRYPT_DIR" ]; then
    mkdir -p "$LETSENCRYPT_DIR" || { echo "Erro ao criar diretório: $LETSENCRYPT_DIR"; exit 1; }
fi

docker run --rm -p 80:80 \
  -v "./certs/certbot/conf:/etc/letsencrypt" \
  -v "./certs/certbot/www:/var/www/certbot" \
  certbot/certbot certonly --standalone \
  -d "$DOMAIN" --agree-tos -n -m "$EMAIL"

