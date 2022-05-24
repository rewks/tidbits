#!/bin/bash

golang=https://go.dev/dl/go1.18.2.linux-amd64.tar.gz
bloodhound=https://github.com/BloodHoundAD/BloodHound/releases/download/4.1.0/BloodHound-linux-x64.zip

# Update repo lists and upgrade packages
sudo apt update
sudo apt upgrade -y

# Update all python packages and ruby gems
pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 sudo pip3 install -U
pipx upgrade-all
sudo gem update

# Update GO if installed version is older than version in variable link
if ! echo $golang | grep -q $(go version | cut -d ' ' -f 3); then
    sudo wget $golang -O /root/go.tar.gz
    sudo tar -xf /root/go.tar.gz -C /root/
    sudo rm -rf /usr/local/go
    sudo mv /root/go /usr/local/
fi

# Update Cloud CLI tools
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws/ awscliv2.zip

sudo az upgrade

# Re-install standalone scripts/tools
sudo wget https://raw.githubusercontent.com/rewks/tidbits/main/crtsh_search.py -O /usr/local/bin/crtsh_search.py
sudo chmod +x /usr/local/bin/crtsh_search.py
sudo wget https://raw.githubusercontent.com/rewks/tidbits/main/sort_domains.py -O /usr/local/bin/sort_domains.py
sudo chmod +x /usr/local/bin/sort_domains.py
sudo wget https://raw.githubusercontent.com/rewks/tidbits/main/rsg.sh -O /usr/local/bin/rsg
sudo chmod +x /usr/local/bin/rsg
sudo wget https://raw.githubusercontent.com/rewks/tidbits/main/netscan.sh -O /usr/local/bin/netscan
sudo chmod +x /usr/local/bin/netscan
sudo wget https://raw.githubusercontent.com/rewks/tidbits/main/ipexpander.py -O /usr/local/bin/ipexpander.py
sudo chmod +x /usr/local/bin/ipexpander.py

# Re-install onesixtyone
cd /tmp
git clone https://github.com/trailofbits/onesixtyone.git
cd onesixtyone
gcc -o onesixtyone onesixtyone.c
sudo mv onesixtyone /usr/local/bin/onesixtyone
cd ~ && rm -rf /tmp/onesixtyone

# Update GO tools
go install github.com/sensepost/gowitness@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/ffuf/ffuf@latest
go install github.com/ropnop/kerbrute@latest

# Update cloned repos
cd /opt/Responder && git pull
cd /opt/sqlmap && git pull
cd /opt/enum4linux-ng && git pull
cd /opt/testssl && git pull
cd /opt/jwt_tool && git pull
cd ~

# Update Bloodhound and ingestors
cd /opt
wget $bloodhound
7z x BloodHound-linux-x64.zip && rm BloodHound-linux-x64.zip
chmod +x /opt/BloodHound-linux-x64/BloodHound
cd ~/tools/windows
wget https://github.com/BloodHoundAD/BloodHound/raw/master/Collectors/SharpHound.exe
wget https://github.com/BloodHoundAD/BloodHound/blob/master/Collectors/AzureHound.ps1
cd ~

# Update wordlists
cd ~/wordlists
git pull
wget https://raw.githubusercontent.com/rewks/tidbits/main/injection_lists/sql.txt -O sqli.txt
wget https://raw.githubusercontent.com/rewks/tidbits/main/injection_lists/xss.txt -O xxs.txt
cd ~