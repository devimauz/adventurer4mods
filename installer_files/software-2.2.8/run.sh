#!/bin/sh

# Author:		和岩波
# Description:	单个固件包升级程序
# Date:			2019-10-28

set -x

WORK_DIR=`dirname $0`

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

# cp -vf /tmp/test /data/
# $1  源文件路径名 /tmp/test
# $2  目标路径名   /data/
cp_file()
{
	SRCFILE="$1"
	DSTFILE="$2`basename $1`"
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

if [ -f $WORK_DIR/auto_run.sh ]; then
    echo "update auto_run.sh"
    cp_file $WORK_DIR/auto_run.sh /opt/
fi

if [ -f $WORK_DIR/nozzle_remover.gx ]; then
    echo "update nozzle_remover.gx"
    cp_file $WORK_DIR/nozzle_remover.gx /data/
fi

exit 0
