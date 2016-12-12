#!/bin/bash


rm -f ./tmp/lsls

up=$(grep -i -E \;up ../Partage/updown | cut -d";" -f1)
down=$(grep -i -E \;down ../Partage/updown | cut -d";" -f1)
countu=$[$(echo $up | grep -o " " | wc -l)+1]
countd=$[$(echo $down | grep -o " " | wc -l)+1]


cd "../Partage"
unzip *.zip
rm *.zip
ls -d */ | cut -d "/" -f 3 >> ../scripts/tmp/lsls
cd "../scripts"

i="1"
j="1"

while read p; do
	if [ -d "/var/www/$p" ]; then
		tar -zcvf "$p"-`date "+%d.%m.%Y"`.tar.gz /var/www/$p
		rm -rf /var/www/$p
		mv "$p"-`date "+%d.%m.%Y"`.tar.gz ../backup
		mv ../Partage/$p /var/www/"$p"
	else
		mv ../Partage/$p /var/www/"$p"
	fi

done <./tmp/lsls

while [ $i -le $countu ]; do
	p="$(echo $up | cut -d " " -f$i)"
	if [ ! -f /etc/apache2/sites-available/$p.project.fr.conf ]; then
		cat <<FinCat >> /etc/apache2/sites-available/$p.project.fr.conf
<VirtualHost $p.project.fr>
	ServerName $p.project.fr 

	ServerAdmin webmaster@localhost
	ServerPath "/var/www/$p/"
	DocumentRoot "/var/www/$p/"
	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined

	<Directory "/var/www/$p/">
		Order Allow, Deny
		Allow from all
		Satisfy Any
	</Directory>

</VirtualHost>

FinCat

	else

		sed '/Deny from all/d' /etc/apache2/sites-available/$p.project.fr.conf
		sed -i '/Allow from 10.0.2/c\Allow from all' /etc/apache2/sites-available/$p.project.fr.conf

	fi

	sh ./script_dns.sh $p
	a2ensite $p.project.fr.conf

	i=$[$i+1]
done

while [ $j -le $countd ]; do
	p="$(echo $down | cut -d " " -f$j)"

	if [ ! -f /etc/apache2/sites-available/$p.project.fr.conf ]; then

		cat <<FinCat >> /etc/apache2/sites-available/$p.project.fr.conf
<VirtualHost $p.project.fr>
	ServerName $p.project.fr

	ServerAdmin webmaster@localhost
	ServerPath "/var/www/$p/"
	DocumentRoot "/var/www/$p/"
	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APPACHE_LOG_DIR}/access.log combined

	<Directory "/var/www/$p/">
		Order Deny, Allow
		Deny from all
		Allow from 10.0.2
		Satisfy Any
	</Directory>

</VirtualHost>

FinCat

	else
		sed '/Allow from all$/,$d' /etc/apache2/sites-available/$p.project.fr.conf # Supprime les lignes après Allow from all

	cat <<FinCat >> /etc/apache2/sites-available/$p.project.fr.conf
	<Directory "/var/www/$p/">
		Order Deny, Allow
		Deny from all
		Allow from 10.0.2
		Satisfy Any
	</Directory>

</VirtualHost>

FinCat

	fi
	a2ensite $p.project.fr.conf
	sh ./script_dns.sh $p
j=$[$j+1]
done


# Boucle pour le dns local où tous les sites sont accessibles
service bind9 reload
service apache2 reload
