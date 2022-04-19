#!/bin/bash
mkdir -p netscan_logs

target=$1

## Fast port scan
echo "[*] Finding open TCP ports for $target"
tcp_ports=$(nmap -Pn -n -p- -T4 --open $target | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)

## Detailed scan of open TCP ports
echo "[*] Performing detailed TCP scan on $target"
nmap -Pn -n -p $tcp_ports -sT -sV -sC -oN netscan_logs/${target}_tcp.nmap $target 1>/dev/null
grep '^[0-9]*/tcp' netscan_logs/${target}_tcp.nmap >> netscan_logs/${target}_services.list

## Detailed scan of top 15 UDP ports if sudo doesnt require pw
if sudo -n true 2>/dev/null; then
  echo "[*] Performing detailed UDP scan on $target"
  sudo nmap -Pn -n --top-ports 15 -T4 -sU -sV -sC --open -oN netscan_logs/${target}_udp.nmap $target 1>/dev/null
  grep '^[0-9]*/udp' netscan_logs/${target}_udp.nmap | grep -v filtered >> netscan_logs/${target}_services.list
fi

## Add TCP services to master file
grep '^[0-9]*/tcp' netscan_logs/${target}_tcp.nmap | sed s/^/${target}:/ | sed 's/\/tcp.*$//' >> netscan_service_list.list
