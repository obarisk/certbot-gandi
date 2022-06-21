#!/usr/bin/env sh

mkdir -p certbot/etc
mkdir -p certbot/log

if [ -n "$DOCKER" ]; then
  alias podman=docker
fi

case $1 in
  debug)
    podman run -it --rm \
      --name certbot-gandi \
      -v "$(realpath ./certbot/etc)":/etc/letsencrypt \
      -v "$(realpath ./certbot/log)":/var/log/letsencrypt \
      -v "$(realpath ./hooks)":/hooks \
      --entrypoint /bin/sh \
      docker.io/certbot/certbot:latest
    ;;
  shell)
    shift
    podman run -it --rm \
      --name certbot-gandi \
      -v "$(realpath ./certbot/etc)":/etc/letsencrypt \
      -v "$(realpath ./certbot/log)":/var/log/letsencrypt \
      -v "$(realpath ./hooks)":/hooks \
      --entrypoint /bin/sh \
      docker.io/certbot/certbot:latest \
      -c "$@"
    ;;
  *)
    podman run -it --rm \
      --name certbot-gandi \
      -e "GANDI_APIKEY=$GANDI_APIKEY" \
      -e "GANDI_DOMAIN=$GANDI_DOMAIN" \
      -v "$(realpath ./certbot/etc)":/etc/letsencrypt \
      -v "$(realpath ./certbot/log)":/var/log/letsencrypt \
      -v "$(realpath ./hooks)":/hooks \
      docker.io/certbot/certbot:latest \
      "$@"
    ;;
esac

# run posthooks
if [ "$1" = "certonly" ] || [ "$1" = "renew" ]; then
  find posthooks/pre -type f -executable -exec '{}' ';'
  find posthooks/post -type f -executable -exec '{}' ';'
fi
