#!/bin/bash

rm -f ./tmp/lsls ./tmp/upfinal ./tmp/downfinal

up=$(grep -i -E \;up ../Project/updown | cut -d";" -f1)
down=$(grep -i -E \;down ../Project/updown | cut -d";" -f1)
countu=$[$(echo $up | grep -o " " | wc -l)+1]
countd=$[$(echo $down | grep -o " " | wc -l)+1]

ls -d ../Project/*/ | cut -d "/" -f 3 >> ./tmp/lsls

i="1"
j="1"

while read p; do
	if [ -d "/var/www/$p" ]; then
		tar -zcvf "$p"-`date "+%d.%m.%Y"`.tar.gz /var/www/$p
		rm -rf /var/www/$p
		mv "$p"-`date "+%d.%m.%Y"`.tar.gz ../backup
		mv ../Project/$p /var/www/"$p"
	else 
		mv ../Project/$p /var/www/"$p"
	fi

done <./tmp/lsls

while [ $i -le $countu ]
do
	p="$(echo $up | cut -d " " -f$i)"
	if [ ! -f /etc/apache2/sites-available/$p.project.fr.conf ]; then
		cat <<-FinCat >> /etc/apache2/sites-available/$p.project.fr.conf
		<VirtualHost $p.project.fr>
			ServerName $p.project.fr.conf

			ServerAdmin webmaster@localhost
			ServerPath "/var/www/$p/"
			DocumentRoot "/var/www/$p"
			ErrorLog \${APACHE_LOG_DIR}/error.log
			CustomLog \${APACHE_LOG_DIR}/access.log combined
		</VirtualHost>

		FinCat
	fi

	echo $p >> ./tmp/upfinal
	a2ensite $p.project.fr.conf

	i=$[$i+1]
done

while [ $j -le $countd ]
do
	p="$(echo $down | cut -d " " -f$j)"
	echo $p >> ./tmp/downfinal
	a2dissite $p.project.fr.conf
	j=$[$j+1]
done

service apache2 reload
