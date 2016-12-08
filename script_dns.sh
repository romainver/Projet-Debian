#!/bin/bash

if [ ! -a /etc/bind/db.$1.project.fr ]; then

#Création du fichier de zone

cat << NFFS > /etc/bind/db.$1.project.fr

\$TTL	604800
@	IN	SOA	PS.$1.project.fr. root.$1.project.fr. (
			1
			604800
			86400
			2419200
			604800 )
@	IN	NS	PS.$1.project.fr.

PS	IN	A	10.0.2.15 # Modifier l'ip en fonction de la machine utilisée

NFFS

cat << LZF >> /etc/bind/named.conf.local

zone "$1.fr" IN {
	type master;
	file "etc/bind/db.$1.project.fr";
};

LZF

bind="/etc/init.d/bind9 restart"

eval $bind


# Création du fichier de zone inversée

cat << ILZF > /etc/bind/named.conf.local

zone "2.0.10.in-addr.arpa" { # Modifier l'ip inversée en fonction de la machine utilisée
	type master;
	notify no;
	file "/etc/bind/db.10";
};

ILZF

cat << DBIF >> /etc/bind/db.10

\$TTL	604800
@	IN	SOA	PS.$1..project.fr. root.$1.project.fr. (
			2
			604800
			86400
			2419200
			604800 )
@	IN	NS	PS.$1.project.fr.
10	IN	PTR	PS.$1.project.fr.

DBIF

eval $bind

fi
