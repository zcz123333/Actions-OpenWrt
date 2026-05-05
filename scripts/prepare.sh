#!/bin/bash

set -eu

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPTS_DIR"
cd ../
TOP_DIR=$(pwd)

cd project/openwrt
./scripts/feeds update -a && ./scripts/feeds install -a
if [ $? -ne 0 ]; then
	echo "====Building openwrt failed!===="
	exit 1
fi

rm -f .config
touch .config


if [ -d ${TOP_DIR}/configs/rockchip ]; then
	CURRPATH=$PWD
	readonly CURRPATH
	touch ${CURRPATH}/.config
	(cd ${TOP_DIR}/configs/rockchip && {
		for FILE in $(ls); do
			if [ -f ${FILE} ]; then
				echo "# apply ${FILE} to .config"
				cat ${FILE} >> ${CURRPATH}/.config
			fi
		done
	})
else
	cp ${TOP_DIR}/configs/rockchip .config
fi
sed -i -e '/^# CONFIG_PACKAGE_kmod-/d' .config

make defconfig

echo "prepare .config file done"