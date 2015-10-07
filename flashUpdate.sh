#!/bin/bash
color="\e[1m\e[34m"; #Color Azul con negrita
end="\e[0m";

echo -e "$color ## Actualizando Flash de Chromium $end";
./chromium.sh
echo -e "$color ## Actualizando Flash de FireFox y derivados $end";
./firefox.sh
sleep 5
