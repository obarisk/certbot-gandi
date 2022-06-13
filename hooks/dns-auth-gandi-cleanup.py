#!/usr/bin/env python3

"""
cleanup dns challenge
"""

import os
import requests

GANDI_URL = "https://api.gandi.net/v5"

def main():
	"""main"""
	GK = os.getenv("GANDI_APIKEY")
	GD = os.getenv("GANDI_DOMAIN")
	res = requests.get(f"{GANDI_URL}/livedns/domains/{GD}/records",
			headers={"Authorization": f"Apikey {GK}"})
	if res.status_code < 200 or res.status_code >= 300:
		raise ConnectionError(f"unable to get records for domain {GD} from gandi")
	for j in res.json():
		if j.get("rrset_name").startswith("_acme-challenge"):
			res = requests.delete(
					f"{GANDI_URL}/livedns/domains/{GD}/records/{j.get('rrset_name')}",
					headers={"Authorization": f"Apikey {GK}"})
			print(f"found txt record {j}. deletion status = {res.status_code}")

if __name__ == "__main__":
	main()
