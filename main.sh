#!/usr/bin/env sh

if [ "$1" != "renew" ] && [ "$1" != "certonly" ] && [ "$1" != "test" ]; then
  echo "unsupport command. allow only renew and certonly subcommand"
  exit 1
fi

if [ -n "$DOCKER" ]; then
  alias podman=docker
fi

CONTAINER_VOLUME_ETC=${CONTAINER_VOLUME_ETC:-certbot-etc}
CONTAINER_VOLUME_LOG=${CONTAINER_VOLUME_LOG:-certbot-log}

if [ "$1" = "certonly" ]; then
  if ! podman volume inspect "$CONTAINER_VOLUME_LOG" >/dev/null 2>&1; then
    podman volume create "$CONTAINER_VOLUME_LOG"
  fi
  if ! podman volume inspect "$CONTAINER_VOLUME_ETC" >/dev/null 2>&1; then
    podman volume create "$CONTAINER_VOLUME_ETC"
  fi
  podman run --rm \
    -e "GANDI_APIKEY=$GANDI_APIKEY" \
    -e "GANDI_DOMAIN=$GANDI_DOMAIN" \
    -v "$CONTAINER_VOLUME_ETC":/etc/letsencrypt \
    -v "$CONTAINER_VOLUME_LOG":/var/log/letsencrypt \
    -v "$(realpath ./hooks)":/hooks \
    docker.io/certbot/certbot:latest \
    "$@"
fi

if [ "$1" = "renew" ]; then
  if ! podman volume inspect "$CONTAINER_VOLUME_LOG" >/dev/null 2>&1; then
    echo "unable to renew without existed certs"
    exit 1
  fi
  if ! podman volume inspect "$CONTAINER_VOLUME_ETC" >/dev/null 2>&1; then
    echo "unable to renew without existed certs"
    exit 1
  fi
  podman run --rm \
    -e "GANDI_APIKEY=$GANDI_APIKEY" \
    -e "GANDI_DOMAIN=$GANDI_DOMAIN" \
    -v "$CONTAINER_VOLUME_ETC":/etc/letsencrypt \
    -v "$CONTAINER_VOLUME_LOG":/var/log/letsencrypt \
    -v "$(realpath ./hooks)":/hooks \
    docker.io/certbot/certbot:latest \
    "$@"
fi

find posthooks/ -type f -executable -exec '{}' ';'

if [ -d certs ]; then
  mv certs "hist/certs-$(date "+%s%N")"
fi
podman run -d \
  --name certbot-gandi \
  --entrypoint "/bin/sleep" -v "$CONTAINER_VOLUME_ETC":/certs \
  docker.io/certbot/certbot:latest \
  3600
podman cp certbot-gandi:/certs .
podman stop certbot-gandi
podman rm certbot-gandi
