#!/bin/bash

if [ ! -f /etc/bind/db.$1.project.fr ]; then

	#Création du fichier de zone

	cat <<NFFS > /etc/bind/db.$1.project.fr

\$TTL	604800
@	IN	SOA	PS.$1.project.fr. root.$1.project.fr. (
			1
			604800
			86400
			2419200
			604800 )
@	IN	NS	PS.$1.project.fr.

PS	IN	A	10.0.2.20 # Modifier l'ip en fonction de la machine utilisée

NFFS

	cat <<LZF >> /etc/bind/named.conf.local

zone "$1.fr" IN {
	type master;
	file "etc/bind/db.$1.project.fr";
};

LZF


	# Création du fichier de zone inversée

	cat <<ILZF >> /etc/bind/named.conf.local

zone "2.0.10.in-addr.arpa" { # Modifier l'ip inversée en fonction de la machine utilisée
	type master;
	notify no;
	file "/etc/bind/db.$1.project.inv";
};

ILZF

	cat <<DBIF >> /etc/bind/db.$1.project.inv

\$TTL	604800
@	IN	SOA	PS.$1..project.fr. root.$1.project.fr. (
			2
			604800
			86400
			2419200
			604800 )
@	IN	NS	PS.$1.project.fr.
20	IN	PTR	PS.$1.project.fr. # Le numéro correspond au dernier élément de l'adresse IP uilisée

DBIF

fi
