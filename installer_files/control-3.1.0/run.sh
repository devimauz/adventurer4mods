#!/bin/sh
# Author:		和岩波
# Description:	单个固件包升级程序
# Date:			2019-10-28

set -x

WORK_DIR=`dirname $0`

FIRMWARE_M3_NA=Adventurer4-NA-IAP.hex
FIRMWARE_M3_HD=Adventurer4-HD-IAP-2.1.0-20220411.hex

#检测机器的架构,错误马上退出
CHECH_ARCH=`uname -m`
if [ "${CHECH_ARCH}" != "armv7l" ];then
    echo "Machine architecture error."
    echo ${CHECH_ARCH}
    exit 1
fi

#检测内核版本，错误马上退出
CHECH_KERNEL=`uname -r`
if [ "${CHECH_KERNEL}" != "3.4.39+" ];then
    echo "Kernel version error."
    echo ${CHECH_KERNEL}
    exit 1
fi

if [ -f $WORK_DIR/IAPCommand ];then
	chmod a+x $WORK_DIR/IAPCommand
	if [ -f $WORK_DIR/$FIRMWARE_M3_NA -a -f $WORK_DIR/$FIRMWARE_M3_HD ];then
		echo "burn M3 firmware..."
		$WORK_DIR/IAPCommand $WORK_DIR/$FIRMWARE_M3_NA $WORK_DIR/$FIRMWARE_M3_HD
	fi
fi

exit 0
