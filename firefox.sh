#!/bin/bash
#Carpeta en la que se encuentra la versión flash anterior
flashlocation="/usr/lib/flashplugin-nonfree/"
link="https://get.adobe.com/flashplayer/download/?installer=Flash_Player_11.2_for_other_Linux_%28.tar.gz%29_64-bit&standalone=1"
flashtar="FP.tar.gz"
flashlib="libflashplayer.so"
helper="helper.html"
fvold=`cat FFflashversion`
color="\e[1m\e[31m"; #Color Rojo  con negrita
end="\e[0m";

wget -nv --show-progress --no-check-certificate -O $helper $link
# Parsea la URL de donde descargar flash del HTML descargado.
link1=`cat $helper|grep "setTimeout(\"location.href ="|awk -F\' '{ print $2 }'`
# Determina la versión de flash
fv=`echo $link1|awk -F/ '{print $7}'`

echo -e "$color # Version anterior de flash $fvold $end"
echo -e "$color # Version actual de flash $fv $end"

if [ "$fvold" = "$fv" ]; then
    #Si la version es la misma que la guardada en el archivo sale.
    echo -e "$color # No hay nada que hacer, Las versiones son iguales $end"
else
    #Si la version no concuerda o no hay archivo de guardado...
    echo $fv > FFflashversion
    echo -e "$color # Descargando nueva version de flash $end"
    wget -nv --show-progress --no-check-certificate -O $flashtar $link1
    echo -e "$color # Desempaquetando $end"
    tar -xzf $flashtar $flashlib
    echo -e "$color # Copiando $end"
    sudo cp -f ./$flashlib $flashlocation
    echo -e "$color # Eliminando archivos temporales $end"
    rm $flashlib $flashtar
fi
rm $helper
