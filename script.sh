#!/bin/bash
#Script to add users to a debian system with a list of users

#Check if running as root
root=$(whoami)
if [ root != $root ]
then
	echo "Needs to run with root privileges"
	echo "sudo ./script.sh"
	exit
fi

#add user list to variable
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
	apt install whois
	fi
fi

#Generate random password that is added to passlist.txt
> passlist.txt
for i in $file;
do
	pass=$(dd if=/dev/urandom bs=1 count=8 status=none|base64 -w 0)
	echo $i:$pass >> passlist.txt
done


#Add username and password to variables and add users with useradd
#Uses sha512 encryption in /etc/shadow format

list=$(cat passlist.txt)

for line in $list; do
	user=$(echo $line | awk -F ":" '{print $1}')
	pass=$(echo $line | awk -F ":" '{print $2}')
	usercheck=$(cat /etc/passwd | grep $user)
	if [ -z $usercheck ]
	then
                crypt=$(mkpasswd -m sha-512 $pass)
                useradd -m -U -p $crypt $user
                passwd --expire $user >/dev/null
                echo "Added user: "$user

	else
		echo $user "not added, already exitst"

	fi
done
