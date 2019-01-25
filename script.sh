#!/bin/bash
#Script to add users to a debian system with a list of users
#list.txt must have the format user:password

#add users to variable
file=$(cat list.txt)

#Check if mkpasswd is installed (whois utils)
mkpasswd=$(dpkg -l | grep whois)
if [ -z "$mkpasswd" ]
then
	echo "whois util not installed, install? y/n"
	read install
	var=y
	if [ $install = $var ]
	then
	sudo apt install whois
	fi
else	echo "Installed"
fi

#Add username and password to variables and add users with useradd
#Uses sha512 encryption in /etc/shadow format

> passlist.txt
for i in $file;
do
	pass=$(dd if=/dev/urandom bs=1 count=5|base64 -w 0)
	echo $i:$pass >> passlist.txt
done

list=$(cat passlist.txt)

for line in $list; do
	user=$(echo $line | awk -F ":" '{print $1}')
	pass=$(echo $line | awk -F ":" '{print $2}')
	crypt=$(mkpasswd -m sha-512 $pass)
	useradd -m -U -p $crypt $user
	passwd --expire $user
done
