#!/bin/bash

URL="https://www.fomento.gob.es/informacion-para-el-ciudadano/empleo-publico/procesos-selectivos/convocatorias-2017/personal-funcionario/cuerpo-ingenieros-caminos-canales-y-puertos-del-estado-acceso-libre-y-promocion"
DOWNLOADED_SITE=$(echo -n $URL | awk -F/ '{print $NF}')
ORIGINAL_SITE="$DOWNLOADED_SITE.original"
#MD5SUM_ORIG=$(/usr/bin/md5sum $ORIGINAL_SITE | cut -f1 -d" ")
MD5SUM_ORIG=$(cat $ORIGINAL_SITE | awk '/Aprobados 2º ejercicio/ {for(i=1; i<=15; i++) {getline; print}}' | /usr/bin/md5sum | cut -f1 -d" ")

while [ 1 == 1 ]
do
	if [ -f $DOWNLOADED_SITE ]; then
		rm -f $DOWNLOADED_SITE
	fi

	wget -U "Opera 11.0" $URL

	#MD5SUM=$(/usr/bin/md5sum $DOWNLOADED_SITE | cut -f1 -d" ")
	MD5SUM=$(cat $DOWNLOADED_SITE | awk '/Aprobados 2º ejercicio/ {for(i=1; i<=15; i++) {getline; print}}' | /usr/bin/md5sum | cut -f1 -d" ")
	echo $MD5SUM
	echo $MD5SUM_ORIG
	if [ "$MD5SUM" != "$MD5SUM_ORIG" ]; then
		paplay /usr/share/sounds/ubuntu/ringtones/Alarm\ clock.ogg
	fi

	sleep 60
done
