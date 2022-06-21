# certbot gandi plugin

- [gandi-api](https://api.gandi.net/docs/)
- [dns-01-challenge](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge)
- [certbot-renew](https://eff-certbot.readthedocs.io/en/stable/using.html#setting-up-automated-renewal)

## example (dryrun)

```sh
export GANDI_APIKEY
export GANDI_DOMAIN

./main.sh certonly -v \
  --dry-run \
  --preferred-challenges dns \
  --agree-tos \
  --email "whoami@mydomain.net" \
  -d "mydomain.net" \
  -d "*.mydomain.net" \
  --manual \
  --manual-auth-hook    "/hooks/dns-auth-gandi.py" \
  --manual-cleanup-hook "/hooks/dns-auth-gandi-cleanup.py"
```
