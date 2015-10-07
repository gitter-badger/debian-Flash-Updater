#!/bin/bash

#Lugar en donde se guardará flash
flashloc="/opt/chromium/PepperFlash";
bits=64; #Modificar en caso de Arquitectura diferente.
version="stable" #Tipo de rama. "stable" o "unstable"



color="\e[1m\e[31m"; #Color Rojo  con negrita
end="\e[0m";
nodel=false; #Para evitar el borrado automatico
nodown=false; #Evita volver a descargar el archivo
if [ $bits -eq "64" ];then
	arq="amd64"
else
	arq="i386"
fi
link="https://dl.google.com/linux/direct/google-chrome-${version}_current_$arq.deb"
echo -e "$color # Se procede a descargar $link $end"
outfile="chrome.deb"
if [ $nodown = false ];then
	wget -nv --show-progress --no-check-certificate -O $outfile $link
fi

#Puede que en versiones posteriores las rutas cambien y deban ser modificadas
if [ $version = "stable" ];then
#	ar p $outfile data.tar.lzma|tar -x --lzma #Comentado. Antes usaban lzma. Lo dejo por si vuelven a cambiarla
	ar p $outfile data.tar.xz|tar -x --xz #Si no se tiene previsto cambiarlo se podría sacar del if.
	tarloc="./opt/google/chrome/PepperFlash"
else
	ar p $outfile data.tar.xz|tar -x --xz
	tarloc="./opt/google/chrome-unstable/PepperFlash"
fi
cp -R $tarloc ./PepperFlash/

#Recoge la versión anterior
fvold=`cat $flashloc/manifest.json|grep version|awk -F\" '{ print $4 }'`
echo -e "$color # Version anterior de flash $fvold $end"

#Recoge la version actual descargada.
fv=`cat PepperFlash/manifest.json|grep version|awk -F\" '{ print $4 }'`
echo -e "$color # Version actual de flash $fv $end"


if [ $fvold != $fv ];then
	echo -e "$color # Creando script para darle poderes de supervaca $end"
	#Ya que necesita de privilegios de admin, genera un sh para ejecutarlo con sudo.

	#Copia flash en la ruta indicada
	echo "cp -f PepperFlash/* $flashloc/" >superscript.sh
	#Genera una copia de seguridad en caso de error.
	echo "cp /etc/chromium.d/chromeFlags ./chromeFlags.old" >>superscript.sh
	#Intercambia las versiones en chromeFlags1
	echo "cat /etc/chromium.d/chromeFlags|sed \"s/$fvold/$fv/g\" > /etc/chromium.d/chromeFlags1">>superscript.sh
	#renombra Flags1 a chromeFlags.
	echo "mv -f /etc/chromium.d/chromeFlags1 /etc/chromium.d/chromeFlags">>superscript.sh

	echo -e "$color # Ejecutando script con poderes de supervaca!$end"
	sudo sh superscript.sh
	rm superscript.sh
else
	echo -e "$color # Las versiones son iguales o hubo error. Se procede a abortar.$end"
fi

if [ $nodel = false ];then
	echo -e "$color # Eliminando archivos.$end"
	rm -rf opt/ etc/ usr/
	rm -rf PepperFlash
	rm $outfile
fi
