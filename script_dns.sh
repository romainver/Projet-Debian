#!/bin/bash

if [ !-a /etc/bind/db.$1.fr ]; then

cat << EndOfFile > /etc/bind/db.$1.fr

$TTL	86400
@	IN	SOA	ProjectScripting.$1.fr root.$1.fr. (
			1
			604800
			86400
			2419200
			76400 )
@	IN	NS	ProjectScripting.$1.fr.
ProjectScripting	IN	A	10.0.2.15

EndOfFile

cat << EndOfSecondFile > /etc/bind/named.conf.local

zone "$1.fr"{
	type master;
	file "etc/bind/db.$1.fr";
}

EndOfSecondFile

bind="service bind9 reload"

eval $bind

fi


