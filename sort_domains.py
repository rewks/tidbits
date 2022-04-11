#!/usr/bin/env python3
import sys

domains_file = sys.argv[1]
f = open(domains_file, 'r')

domains = []
for l in f:
    domains.append(l)

for d in sorted([x.strip().split('.')[::-1] for x in domains]): print('.'.join(d[::-1]))
