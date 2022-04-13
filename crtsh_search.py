#!/usr/bin/env python3
import requests
import sys
import re

url = sys.argv[1].lower()
rData = requests.get(f'https://crt.sh/?q={url}')

escaped_url = url.replace('.', '\\.')
pattern = r'(?:(?!-)[A-Za-z0-9-*]{1,63}(?<!-)\.)+' + escaped_url
prog = re.compile(pattern, re.MULTILINE)
domains = prog.findall(rData.text.lower())

uniqueDomains = list(dict.fromkeys(domains))

for d in sorted([x.strip().split('.')[::-1] for x in uniqueDomains]): print('.'.join(d[::-1]))
