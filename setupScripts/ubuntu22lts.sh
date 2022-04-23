#!/bin/bash

golang=https://go.dev/dl/go1.18.1.linux-amd64.tar.gz
portainer=cr.portainer.io/portainer/portainer-ce:2.11.1
bloodhound=https://github.com/BloodHoundAD/BloodHound/releases/download/4.1.0/BloodHound-linux-x64.zip

# Update repo lists and upgrade packages
sudo apt update
sudo apt upgrade -y

# Get rid of crap and stop rdp service being super persistent
sudo systemctl stop cups.service
sudo systemctl stop cups-browsed.service
sudo systemctl stop cups.path
sudo systemctl stop cups.socket
sudo systemctl disable cups.service
sudo systemctl disable cups-browsed.service
sudo systemctl disable cups.path
sudo systemctl disable cups.socket
sudo apt purge cups -y
sudo rm -rf /etc/cups
sudo systemctl stop avahi-daemon
sudo systemctl stop avahi-daemon.socket
sudo systemctl disable avahi-daemon
sudo systemctl disable avahi-daemon.socket
sudo apt purge avahi-daemon -y
sudo rm -rf /etc/avahi
sudo unlink /etc/systemd/user/gnome-session.target.wants/gnome-remote-desktop.service
systemctl stop --user gnome-remote-desktop

# Install generic packages
sudo apt install apt-transport-https -y
sudo apt install terminator -y
sudo apt install vim -y
sudo apt install git -y
sudo apt install make -y
sudo apt install gcc -y
sudo apt install locate -y
sudo apt install openssh-server -y
sudo systemctl disable ssh
sudo systemctl stop ssh
sudo apt install samba -y
sudo systemctl disable smbd
sudo systemctl stop smbd
sudo systemctl disable nmbd
sudo systemctl stop nmbd
sudo apt install p7zip-full -y
sudo apt install smbclient -y
sudo apt install cewl -y
sudo apt install openconnect -y
sudo apt install flameshot -y
sudo apt install python3.10-venv -y
sudo apt install autoconf -y
sudo apt install parallel -y

# Install libreoffice
sudo apt install libreoffice-calc -y
sudo apt install libreoffice-writer -y

# Install languages and helper packages (pip, ruby, go, dotnet6)
sudo apt install python3-pip -y
sudo apt install ruby-dev -y
sudo wget $golang -O /root/go.tar.gz
sudo tar -xf /root/go.tar.gz -C /root/
sudo mv /root/go /usr/local/
sudo ln -s /usr/local/go/bin/go /usr/local/bin/go
sudo rm /root/go.tar.gz
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb
rm /tmp/packages-microsoft-prod.deb
sudo apt update
sudo apt install dotnet-sdk-6.0 -y

# Docker
sudo apt install ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y

# Portainer
sudo docker volume create portainer_data
sudo docker run -d -p 127.0.0.1:8000:8000 -p 127.0.0.1:9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data $portainer

# IDEs (vs code)
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install code -y

# Install Devops software
sudo apt install software-properties-common -y
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/terraform.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/terraform.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/terraform.list > /dev/null
sudo apt update
sudo apt install terraform -y

sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y

# Install Cloud CLI tools
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws/ awscliv2.zip

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install networking packages
sudo apt install nmap -y
sudo apt install arp-scan -y
sudo apt install proxychains4 -y
sudo apt install chromium-browser -y
sudo apt install netcat-traditional -y
sudo rm /etc/alternatives/nc
sudo ln -s /usr/bin/nc.traditional /etc/alternatives/nc

# Install generic ruby gems/python modules
sudo gem install winrm
sudo gem install winrm-fs
sudo pip3 install ldap3
sudo pip3 install termcolor 
sudo pip3 install cprint 
sudo pip3 install pycryptodomex 
sudo pip3 install requests

# ========= SECURITY TOOLS ==========
# Install security ruby gems/python modules
sudo gem install evil-winrm
sudo gem install wpscan
sudo pip3 install ssh-audit
sudo pip3 install service_identity
sudo pip3 install mitm6
sudo pip3 install impacket
sudo pip3 install pipx
pipx ensurepath
pipx install crackmapexec

# Install standalone scripts/tools
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
sudo wget https://github.com/ropnop/go-windapsearch/releases/download/v0.3.0/windapsearch-linux-amd64 -O /usr/local/bin/windapsearch
sudo chmod +x /usr/local/bin/windapsearch

cd /tmp
mkdir -p nbtscan && cd nbtscan
wget http://www.unixwiz.net/tools/nbtscan-source-1.0.35.tgz && tar -xzf nbtscan-source-1.0.35.tgz && make
sudo mv nbtscan /usr/local/bin/nbtscan
cd ~ && rm -rf /tmp/nbtscan

cd /tmp
git clone https://github.com/trailofbits/onesixtyone.git
cd onesixtyone
gcc -o onesixtyone onesixtyone.c
sudo mv onesixtyone /usr/local/bin/onesixtyone
cd ~ && rm -rf /tmp/onesixtyone

cd /tmp
git clone https://github.com/royhills/ike-scan.git
cd ike-scan
autoreconf --install
./configure
make
sudo mv ike-scan /usr/local/bin/ike-scan
cd ~ && rm -rf /tmp/ike-scan

# Install GO tools
go install github.com/sensepost/gowitness@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/ffuf/ffuf@latest
go install github.com/ropnop/kerbrute@latest

# Clone github repos
sudo chown root:$(whoami) /opt
sudo chmod 774 /opt
cd /opt
git clone https://github.com/lgandx/Responder.git
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git
git clone https://github.com/cddmp/enum4linux-ng.git
git clone --depth 1 https://github.com/drwetter/testssl.sh.git
git clone https://github.com/ticarpi/jwt_tool.git

# Install cracking tools
sudo apt install libssl-dev yasm libpcap-dev libbz2-dev -y
git clone https://github.com/openwall/john -b bleeding-jumbo john
cd john/src
./configure && make -s clean && make -sj4
cd ../..

# Install dotnet core 3.1 and Covenant c2
wget https://download.visualstudio.microsoft.com/download/pr/9be72f63-270d-4b1f-9725-4dab8973c69d/62681fb4630de36e15011fa543c90908/dotnet-sdk-3.1.418-linux-x64.tar.gz -O /tmp/dotnet.tar.gz
mkdir -p /opt/dotnet3.1
tar -xzf /tmp/dotnet.tar.gz -C /opt/dotnet3.1/
rm /tmp/dotnet.tar.gz
git clone --recurse-submodules https://github.com/cobbr/Covenant

# Install metasploit
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
chmod 755 /tmp/msfinstall
sudo /tmp/msfinstall
rm /tmp/msfinstall
sudo mv /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d/

# Install bloodhound
curl -fsSL https://debian.neo4j.com/neotechnology.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/neotechnology-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/neotechnology-keyring.gpg] https://debian.neo4j.com stable 4.1" | sudo tee /etc/apt/sources.list.d/neo4j.list > /dev/null
sudo apt update
sudo apt install neo4j -y
sudo systemctl disable neo4j
sudo systemctl stop neo4j
wget $bloodhound
7z x BloodHound-linux-x64.zip && rm BloodHound-linux-x64.zip
chmod +x /opt/BloodHound-linux-x64/BloodHound

# Gather bloodhound ingestors (.py, .exe, .ps1)
mkdir -p ~/tools/windows
cd ~/tools/windows
sudo pip3 install bloodhound
wget https://github.com/BloodHoundAD/BloodHound/raw/master/Collectors/SharpHound.exe
wget https://github.com/BloodHoundAD/BloodHound/blob/master/Collectors/AzureHound.ps1

# Download useful linux/windows post-compromise tools
mkdir -p ~/tools/linux
mkdir -p ~/tools/windows/sysinternals
cd ~/tools
wget https://github.com/carlospolop/PEASS-ng/releases/download/20220417/linpeas.sh -O linux/linpeas.sh
wget https://raw.githubusercontent.com/Anon-Exploiter/SUID3NUM/master/suid3num.py -O linux/suid3num.py
wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh -O linux/linenum.sh
wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64 -O linux/pspy
cp /usr/bin/nc.traditional linux/nc
chmod +x linux/*
wget https://download.sysinternals.com/files/SysinternalsSuite.zip 
7z e -y SysinternalsSuite.zip -owindows/sysinternals/
rm SysinternalsSuite.zip
wget https://eternallybored.org/misc/netcat/netcat-win32-1.12.zip
7z e -y netcat-win32-1.12.zip -owindows/
rm netcat-win32-1.12.zip windows/Makefile windows/*.txt windows/*.c windows/*.h
wget https://raw.githubusercontent.com/itm4n/PrivescCheck/master/PrivescCheck.ps1 -O windows/PrivescCheck.ps1
wget https://github.com/carlospolop/PEASS-ng/releases/download/20220417/winPEASx64.exe -O windows/winpeasx64.exe
wget https://github.com/carlospolop/PEASS-ng/releases/download/20220417/winPEASx86_ofs.exe -O windows/winpeasx86.exe
cd ~

# Download wordlists
cd ~
git clone https://github.com/danielmiessler/SecLists.git wordlists
wget https://raw.githubusercontent.com/rewks/tidbits/main/injection_lists/sql.txt -O wordlists/sqli.txt
wget https://raw.githubusercontent.com/rewks/tidbits/main/injection_lists/xss.txt -O wordlists/xxs.txt

# Install web/api testing programs
cd /tmp
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
tar -xzf postman.tar.gz 
mv Postman/app /opt/postman
rm -r Postman postman.tar.gz


cd ~

# ========= ALIASES / PATH =========
# Add executable locations to path
echo "export PATH=\$PATH:~/go/bin" >> ~/.bashrc

# Add aliases
echo "alias vi='vim'" >> ~/.bashrc
echo "alias responder='sudo python3 /opt/Responder/Responder.py'" >> ~/.bashrc
echo "alias sqlmap='python3 /opt/sqlmap/sqlmap.py'" >> ~/.bashrc
echo "alias enum4linux-ng='python3 /opt/enum4linux-ng/enum4linux-ng.py'" >> ~/.bashrc
echo "alias testssl='/opt/testssl.sh/testssl.sh'" >> ~/.bashrc
echo "alias jwt_tool='python3 /opt/jwt_tool/jwt_tool.py'" >> ~/.bashrc
echo "alias john='/opt/john/run/john'" >> ~/.bashrc
echo "alias bloodhound='/opt/BloodHound-linux-x64/BloodHound --no-sandbox'" >> ~/.bashrc
echo "alias covenant='sudo /opt/dotnet3.1/dotnet run --project ~/opt/Covenant/Covenant'" >> ~/.bashrc
echo "alias ffuf='ffuf -c -ic -H \"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:99.0) Gecko/20100101 Firefox/99.0\"'" >> ~/.bashrc
echo "alias postman='/opt/postman/Postman'" >> ~/.bashrc

sudo apt autoremove -y 

source ~/.bashrc
