#!/bin/bash

# Update repo lists and upgrade packages
sudo apt update
sudo apt upgrade -y

sudo apt install apt-transport-https -y

sudo apt install terminator

# proxychains
sudo apt install proxychains4 -y

# VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install code

# Docker
sudo apt install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y

# Portainer
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data cr.portainer.io/portainer/portainer-ce:2.9.3

# Install vim and create alias vi=vim
sudo apt install vim -y
echo "alias vi='vim'" >> ~/.bashrc

# locate
sudo apt install locate

# Git
sudo apt install git -y

# Net-Tools (netstat)
sudo apt install net-tools

# SSH server
sudo apt install openssh-server -y
sudo systemctl disable ssh
sudo systemctl stop ssh

# User key pair
ssh-keygen -t rsa -b 2048

# SMB
sudo apt install samba -y
sudo systemctl disable smbd
sudo systemctl stop smbd

# PIP (python installer)
sudo apt install python3-pip -y

# GO language
sudo apt install golang -y

# Ruby
sudo apt install ruby-dev -y
sudo gem install winrm
sudo gem install winrm-fs
sudo gem install evil-winrm

# 7z
sudo apt install p7zip-full -y

# Network discovery
sudo apt install nmap -y
sudo apt install arp-scan -y

mkdir ~/tools
cd tools
git clone https://github.com/lgandx/Responder.git
echo "alias responder='sudo python3 ~/tools/Responder/Responder.py'" >> ~/.bashrc

sudo pip3 install service_identity
sudo pip3 install mitm6

git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git
echo "alias sqlmap='python3 ~/tools/sqlmap/sqlmap.py'" >> ~/.bashrc

git clone https://github.com/cddmp/enum4linux-ng.git
echo "alias enum4linux-ng='python3 ~/tools/enum4linux-ng/enum4linux-ng'" >> ~/.bashrc

git clone https://github.com/SecureAuthCorp/impacket.git
cd impacket
pip3 install .
export PATH=$PATH:~/.local/bin/
cd ..

sudo pip3 install pipx
pipx ensurepath
pipx install crackmapexec

sudo apt install libssl-dev
sudo apt install yasm libpcap-dev libbz2-dev -y
git clone https://github.com/openwall/john -b bleeding-jumbo john
cd john/src
./configure && make -s clean && make -sj4
cd ../..
echo "alias john='~/tools/john/run/john'" >> ~/.bashrc

echo "deb http://httpredir.debian.org/debian stretch-backports main" | sudo tee -a /etc/apt/sources.list.d/stretch-backports.list
sudo apt update
wget -O - https://debian.neo4j.com/neotechnology.gpg.key | sudo apt-key add -
sudo echo 'deb https://debian.neo4j.com stable 4.0' > /etc/apt/sources.list.d/neo4j.list
sudo apt update
sudo apt install neo4j -y
## Go to https://localhost:7474 and log in with neo4j:neo4j to set a new password
## Download latest bloodhound compiled binary, this may have been updated since script was written
wget https://github.com/BloodHoundAD/BloodHound/releases/download/4.0.3/BloodHound-linux-x64.zip
7z x BloodHound-linux-x64.zip
rm BloodHound-linux-x64.zip
echo "alias bloodhound='~/tools/BloodHound-linux-x64/BloodHound --no-sandbox'" >> ~/.bashrc

sudo pip3 install bloodhound
wget https://github.com/BloodHoundAD/BloodHound/raw/master/Collectors/SharpHound.exe -O ~/tools/windows/SharpHound.exe
wget https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Collectors/SharpHound.ps1 -O ~/tools/windows/SharpHound.ps1
wget https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Collectors/AzureHound.ps1 -O ~/tools/windows/AzureHound.ps1

wget https://download.visualstudio.microsoft.com/download/pr/6425056e-bfd5-48be-8b00-223c03a4d0f3/08a801489b7f18e9e73a1378082fbe66/dotnet-sdk-3.1.415-linux-x64.tar.gz
mkdir dotnet3.5
cd dotnet3.5
tar -xzf ../dotnet-sdk-3.1.415-linux-x64.tar.gz
rm ../dotnet-sdk-3.1.415-linux-x64.tar.gz
echo "alias covenant='sudo ~/tools/dotnet3.5/dotnet run --project ~/tools/Covenant/Covenant'" >> ~/.bashrc

cd ~

export GO111MODULE=on
go get -u github.com/ffuf/ffuf
go get -u github.com/tomnomnom/assetfinder
go get -u github.com/tomnomnom/httprobe
go get -u github.com/sensepost/gowitness
go get github.com/OWASP/Amass/v3/...
export PATH=$PATH:~/go/bin/

sudo apt install smbclient -y

sudo wget https://github.com/ropnop/go-windapsearch/releases/download/v0.2.1/windapsearch-linux-amd64 -O /usr/bin/windapsearch
sudo chmod +x /usr/bin/windapsearch

sudo wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64 -O /usr/local/bin/kerbrute
sudo chmod +x /usr/local/bin/kerbrute

sudo apt install cewl -y
mkdir ~/wordlists
cd ~/wordlists
git clone https://github.com/danielmiessler/SecLists.git

cd ~

# Reverse shell one-liners
sudo wget https://raw.githubusercontent.com/rewks/ReverseShellGenerator/master/rsg.sh -O /usr/local/bin/rsg
sudo chmod +x /usr/local/bin/rsg

# nc with execution
sudo apt install netcat-traditional
sudo rm /etc/alternatives/nc
sudo ln -s /usr/bin/nc.traditional /etc/alternatives/nc

# Metasploit
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall
sudo ./msfinstall
rm msfinstall

# Useful scripts/tools folder
mkdir ~/tools/linux
mkdir ~/tools/windows
mkdir ~/tools/windows/sysinternals
cd ~/tools/linux
## Linux recon scripts
wget https://raw.githubusercontent.com/carlospolop/privilege-escalation-awesome-scripts-suite/master/linPEAS/linpeas.sh
wget https://raw.githubusercontent.com/Anon-Exploiter/SUID3NUM/master/suid3num.py
wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
mv LinEnum.sh linenum.sh
## nc binary with execution
cp /usr/bin/nc.traditional nc
## python process/file system observer
wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64
## microsoft sysinternals
cd ~/tools/windows/sysinternals
wget https://download.sysinternals.com/files/SysinternalsSuite.zip
unzip SysinternalsSuite.zip && rm SysinternalsSuite.zip
cd ..
## Windows netcats
wget https://eternallybored.org/misc/netcat/netcat-win32-1.12.zip
unzip netcat-win32-1.12.zip
rm Makefile *.txt *.c *.h netcat-win32-1.12.zip
## Windows recon scripts
wget https://raw.githubusercontent.com/itm4n/PrivescCheck/master/PrivescCheck.ps1
wget https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/winPEAS/winPEASexe/binaries/Obfuscated%20Releases/winPEASx64.exe
wget https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/winPEAS/winPEASexe/binaries/Obfuscated%20Releases/winPEASx86.exe
cd ~

source ~/.bashrc
