#!/bin/sh

WORK_DIR=/opt
MACHINE=Adventurer4
PID=0012

insmod /lib/modules/3.4.39/8188fu.ko

sleep 3

for i in 1 2 3 4;
do
  if [ ! -e /dev/sda$i ]; then
     echo "sda$i not exist"
	 if [ ! -e /dev/sda ];then
     	continue
	 else
	 	echo "find /dev/sda. start mount."
  		mount -t vfat -o rw /dev/sda /mnt
	 fi
  else
  	mount -t vfat -o rw /dev/sda$i /mnt
  fi

  if [ $? -ne 0 ]; then
        echo "mount /dev/sda or /dev/sda$i to /mnt failed"
        continue
  else
  		ls -1t /mnt/Adventurer4*.tgz
		if [ $? -eq 0 ];then
			UPDATEFILE=`ls -1t /mnt/Adventurer4*.tgz | head -n 1`
			if [ -f $UPDATEFILE ];then
				echo "find update file: ${UPDATEFILE}"
				rm -rf /data/update
				cp -a ${UPDATEFILE} /data/
				if [ $? -ne 0 ];then
					rm -rf /data/Adventurer4*.tgz
					sync
					umount /mnt
					break
				fi
				sync
				mkdir -p /data/update
				sync
				SRCFILE="/data/`basename ${UPDATEFILE}`"
				if [ -f ${SRCFILE} ];then
					tar -xzvf ${SRCFILE} -C /data/update/
					sync
					rm -rf ${SRCFILE}
					/data/update/flashforge_init.sh ${MACHINE} ${PID}
					if [ $? -eq 0 ];then
						umount /mnt
						rm -rf /data/update
						sleep 100000
					fi
					umount /mnt
					rm -rf /data/update
					break
				fi
			fi
		fi

        if [ -f /mnt/flashforge_init.sh ]; then
             echo "found /mnt/flashforge_init.sh"
             chmod a+x /mnt/flashforge_init.sh
             /mnt/flashforge_init.sh ${MACHINE} ${PID}
			 if [ $? -eq 0 ];then
				umount /mnt
				sleep 100000
			 fi
             umount /mnt
             break
        fi
        umount /mnt
  fi
done

echo 34 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio34/direction
echo 1 > /sys/class/gpio/gpio34/value
echo 34 > /sys/class/gpio/unexport

if [ -d /data/update ];then
	rm -rf /data/update
fi

rm -rf /data/picture/*.jpg

rm -rf /opt/qt-4.8.6/lib/libQtSql.*
rm -rf /opt/qt-4.8.6/lib/libQtSvg.*
rm -rf /opt/qt-4.8.6/lib/libQtXml.*
rm -rf /opt/qt-4.8.6/lib/libQtTest.*

rm -rf /opt/qt-4.8.6/plugins/imageformats/libqgif.so
rm -rf /opt/qt-4.8.6/plugins/imageformats/libqico.so
rm -rf /opt/qt-4.8.6/plugins/imageformats/libqsvg.so
rm -rf /opt/qt-4.8.6/plugins/imageformats/libqtga.so

ulimit -s 4096

/opt/PROGRAM/ffstartup-arm -f /opt/PROGRAM/ffstartup.cfg &
