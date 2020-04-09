#!/bin/bash

echo "***********************************************"
echo "*    Backup Zimbra para edición Open Source   *"
echo "***********************************************"

##############################################################
# Este script puede ser usado para respaldar el directorio   #
# zimbra. Comprime la carpeta zimbra que se encuentra en la  #
# ruta /opt/zimbra, y posteriormente la comprime y la copia  #
# con la extensión tar.gz. 				     #	
#							     #		
# Este script puede ser útil pero sin ninguna garantía.	     #
#							     #	
##############################################################


date=$(date +%d-%m-%Y)
year=$(date +%Y)

# Ruta de directorio donde se hará el backup.
# Cambiar la ruta si el backup se copiara en
# otro directorio.
path_dst_backup=/home/RespaldoMailZimbra_$year

# Ruta de carpeta donde esta zimbra.
path_src=/opt/zimbra

# Ruta pra log.
path_log=$path_dst_backup/log_$date.log

# Commando para visualizar en que partición está home: # df -h /home
# La ruta puede cambiar dependiendo el directorio en el 
# que se vaya a guardar el backup. La ruta en la mayoría de casos
# puede ser /dev/sda2 Ejemplo: path_dev=/dev/sda2
path_dev=/dev/mapper/centos-root

# Crea la ruta que se declaró en la variable "$path_dst_backup". 
if [ ! -d $path_dst_backup ]; then
	mkdir -p $path_dst_backup
fi

# Espacio de disco disponible.
avail_disk=$(df -m --output=source,avail | grep $path_dev | awk '{print $2}') 

# Conversión de tamaño de disco en GB
size_disk=$(( avail_disk/1024 ))

# Tamaño de directorio en megas de /opt/zimbra
size_path_zimbra=$(du -sm /opt/zimbra | awk '{print $1}')

# Conversión de tamaño de directorio en GB
size_zimbra=$(( size_path_zimbra/1024))

# Si existe ruta, y espacio disponible de disco
# es mayor o igual al tamaño del directorio zimbra entonces crear backup.
if [ -d $path_dst_backup ] && [ $size_disk -ge $size_zimbra ] ; then
	date_before=$(date +%d-%m-%Y-%T)
	echo "********* Iniciando Backup $date_before ******" >> $path_log
	echo "    ... Espacio de disco disponible: " $(df -h --output=source,avail | grep $path_dev | awk '{print $2}' ) >> $path_log
	echo "    ... Tamaño de directorio Zimbra: " $(du -hs $path_src)  >> $path_log

	# Comprime directorio zimbra y lo copia en /home/RespaldoMailZimbra/
	tar -czvf $path_dst_backup/zimbra_$date.tar.gz $path_src
	
	if [ -s $path_dst_backup/zimbra_$date.tar.gz ]; then
		date_after=$(date +%d-%m-%Y-%T)
		echo "******** Respaldo finalizado $date_after ******" >> $path_log
	else
		echo "*** Respaldo tar.gz no creado ****" >> $path_log
	fi
else
	echo  "**** Error al respaldar ***" >> $path_log
fi

