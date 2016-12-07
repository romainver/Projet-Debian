#!/bin/bash

if [ ! -a /etc/bind/db.$1.fr ]; then

cat << NFFS > /etc/bind/db.$1.fr

\$TTL	604800
@	IN	SOA	PS.$1.fr. root.$1.fr. (
			1
			604800
			86400
			2419200
			604800 )
@	IN	NS	PS.$1.fr.

PS	IN	A	10.0.2.15

NFFS

cat << LZF >> /etc/bind/named.conf.local

zone "$1.fr" IN {
	type master;
	file "etc/bind/db.$1.fr";
}

LZF

bind="/etc/init.d/bind9 restart"

eval $bind

cat << ILZF >> /etc/bind/named.conf.local

zone "2.0.10.in-addr.arpa" {
	type master;
	notify no;
	file "/etc/bind/db.10";
}

ILZF

cat << DBIF >> /etc/bind/db.10

\$TTL	604800
@	IN	SOA	PS.$1.fr. root.$1.fr. (
			2
			604800
			86400
			2419200
			604800 )
@	IN	NS	PS.$1.fr.
10	IN	PTR	PS.$1.fr.

DBIF

eval $bind

fi
