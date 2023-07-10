#!/bin/sh
# Author:		和岩波
# Description:	单个固件包升级程序
# Date:			2019-10-28

set -x

WORK_DIR=`dirname $0`

KERNEL_UIMAGE=uImage-AD4-6-20210705
KERNEL_SCRIPT=script.bin
WIFI_DRIVER=8188fu.ko

#检测机器的架构,错误马上退出
CHECH_ARCH=`uname -m`
if [ "${CHECH_ARCH}" != "armv7l" ];then
    echo "Machine architecture error."
    echo ${CHECH_ARCH}
    exit 1
fi

#检测内核版本，错误马上退出
#CHECH_KERNEL=`uname -r`
#if [ "${CHECH_KERNEL}" != "3.4.39+" ];then
#    echo "Kernel version error."
#    echo ${CHECH_KERNEL}
#    exit 1
#fi

cp_file()
{
	SRCFILE="$1"
	DSTFILE="$2"
	if [ ! -f $DSTFILE ];then
		cp -vf ${SRCFILE} $2
		chmod a+x $DSTFILE
	fi
	SRCFILEMD5=`md5sum $SRCFILE | cut -d ' ' -f 1`
	DSTFILEMD5=`md5sum $DSTFILE | cut -d ' ' -f 1`
	while [ "$SRCFILEMD5" != "$DSTFILEMD5" ];
	do
		rm -rf ${DSTFILE}
		cp -vf ${SRCFILE} $2
		chmod a+x $DSTFILE
		sync
		DSTFILEMD5=`md5sum $DSTFILE | cut -d ' ' -f 1`
	done
	#echo ${SRCFILEMD5}
	#echo ${DSTFILEMD5}
}

#upgrade 8818fu
if [ -f $WORK_DIR/$WIFI_DRIVER ];then
	echo "update 8188fu.ko"
	cp_file $WORK_DIR/$WIFI_DRIVER /lib/modules/3.4.39/8188fu.ko
	sync
	sleep 1
fi

#upgrade kernel
if [ -f $WORK_DIR/$KERNEL_UIMAGE ];then
	echo "update uImage"
	mount -t vfat -o codepage=936,iocharset=utf8 /dev/mmcblk0p1 /media
	cp_file $WORK_DIR/$KERNEL_UIMAGE /media/uImage
	sync
	echo "update script"
	cp_file $WORK_DIR/$KERNEL_SCRIPT /media/script.bin
	sync
	umount /media
	sleep 1
fi

exit 0
