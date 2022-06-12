#!/usr/bin/env python3

"""
dns auth plugin for gandi

"""

import os
import time
import requests

GANDI_URL = "https://api.gandi.net/v5"

def main():
	"""main"""
	CD = os.getenv("CERTBOT_DOMAIN")
	CV = os.getenv("CERTBOT_VALIDATION")

	GK = os.getenv("GANDI_APIKEY")
	GD = os.getenv("GANDI_DOMAIN")

	if GK == "" or GD == "":
		raise ValueError("can't find GANDI_APIKEY or GANDI_DOMAIN from environ variable")
	print(f"dns-auth-gandi. gandi = {GD}. domain = {CD}. token = {CV}")

	GH = {"Authorization": f"Apikey {GK}", "Content-Type": "application/json"}
	RN = "_acme-challenge"
	if CD.endswith(GD):
		RN = str(f"_acme-challenge.{CD.replace(GD, '')}"[:-1])
	else:
		raise ValueError(f"{CD} is not a subdomain of {GD}")

	res = requests.get(f"{GANDI_URL}/livedns/domains/{GD}/records", headers=GH)
	if res.status_code != 200:
		raise ConnectionError(f"fail to get dns records from {GD}")

	if RN in [x.get("rrset_name") for x in res.json() if x.get("rrset_type") == "TXT"]:
		res = requests.put(
			f"{GANDI_URL}/livedns/domains/{GD}/records/{RN}", headers=GH,
			json={"items": [
				{"rrset_name": RN, "rrset_type": "TXT", "rrset_ttl": "300", "rrset_values": [CV]}]})
	else:
		res = requests.post(
			f"{GANDI_URL}/livedns/domains/{GD}/records", headers=GH,
			json={"rrset_name": RN, "rrset_type": "TXT", "rrset_ttl": "300", "rrset_values": [CV]})
	if res.status_code > 300 or res.status_code < 200:
		print(res.text)
		raise ConnectionError(f"fail to put/post {RN}")
	print(f"add {RN} record. status = {res.status_code}. message = {res.json()}")
	time.sleep(60)

if __name__ == "__main__":
	main()
