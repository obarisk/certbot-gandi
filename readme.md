# certbot plugins

- [dns-01-challenge](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge)
- [gandi-api](https://api.gandi.net/docs/)

## example

```sh
./main.sh certonly -v \
  --dry-run \
  --preferred-challenges dns \
  --agree-tos \
  --email "whoami@mydomain.net" \
  -d "mydomain.net" \
  -d "*.mydomain.net" \
  --manual \
  --manual-auth-hook "/hooks/dns-auth-gandi.py" \
  --manual-cleanup-hook "/hooks/dns-auth-gandi-cleanup.py"
```
