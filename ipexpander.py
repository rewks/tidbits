#!/usr/bin/env python3
from sys import argv
from ipaddress import IPv4Network

def get_raw_data(user_input):
    raw_data = []
    try:
        f = open(argv[1], 'r')
        for l in f:
            raw_data.append(l.rstrip())
    except:
        raw_data.append(argv[1])

    return raw_data

def convert(item):
    if '/' in item:
        return [str(ip) for ip in IPv4Network(item, False)]
    elif '-' in item:
        return expand_range(item)
    else:
        return [item]

def expand_range(range):
    start = range.split('-')[0].rstrip()
    end = range.split('-')[1].lstrip()

    network = start.rsplit('.', 1)[0] + '.'
    start_host = int(start.rsplit('.', 1)[1])
    if '.' in end:
        end_host = int(end.rsplit('.', 1)[1])
    else:
        end_host = int(end)

    if end_host < start_host:
        print(f'[!] Error: End host value lower than start host in range {range}')
        quit()

    ip_list = []
    while start_host <= end_host:
        ip_list.append(network + str(start_host))
        start_host += 1

    return ip_list


if len(argv) != 2:
    print(f'[!] Usage: {argv[0]} <ip range/file>')
    quit()

raw_ip_list = get_raw_data(argv[1])
finished_list = []
for i in raw_ip_list:
    for ip in convert(i):
        finished_list.append(ip)

for ip in finished_list:
    print(ip)