#!/bin/bash

sudo pip3 install pwntools
sudo pip3 install capstone
sudo pip3 install filebytes
sudo pip3 install keystone-engine
sudo pip3 install ropper
sudo pip3 uninstall ROPgadget -y
sudo pip3 install ROPgadget
echo "alias pattern_create='/opt/metasploit-framework/embedded/framework/tools/exploit/pattern_create.rb'" >> ~/.bashrc
echo "alias pattern_offset='/opt/metasploit-framework/embedded/framework/tools/exploit/pattern_offset.rb'" >> ~/.bashrc

sudo apt install gdbserver -y
echo "set disassembly-flavor intel" >> ~/.gdbinit
cd /opt
git clone https://github.com/pwndbg/pwndbg
cd pwndbg
./setup.sh
cd ..

git clone https://github.com/radareorg/radare2
cd radare2
sys/install.sh
cd ..

wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.1.3_build/ghidra_10.1.3_PUBLIC_20220421.zip -O ghidra.zip
unzip ghidra.zip
rm ghidra.zip
echo "alias ghidra='/opt/ghidra_10.1.3_PUBLIC/ghidraRun'" >> ~/.bashrc

wget https://download.oracle.com/java/18/latest/jdk-18_linux-x64_bin.deb
sudo apt install libc6-i386 libc6-x32
sudo dpkg -i jdk-18_linux-x64_bin.deb
rm jdk-18_linux-x64_bin.deb
cd ~
source .bashrc
