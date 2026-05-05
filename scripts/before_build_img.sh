#!/bin/bash

# apply files
rsync -a --no-o --no-g --progress ../base-files/ openwrt/target/linux/rockchip/armv8/base-files/
rsync -a --no-o --no-g --progress ../kernel-files/ openwrt/package/kernel/linux/files/

echo "cpu = ${MY_CPU}"
if [ "${MY_CPU}" == "rk3328" ]; then
    sed -i 's/CONFIG_TARGET_rockchip_armv8_DEVICE_.*/CONFIG_TARGET_rockchip_armv8_DEVICE_friendlyarm_nanopi-r2s=y/g' ../configs/rockchip/01-nanopi
fi

# patchs
rsync -a --no-o --no-g --progress ../patches/patches-6.12/ openwrt/target/linux/rockchip/patches-6.12/
# fullcone
rsync -a --no-o --no-g --progress ../patches/fullcone/firewall4/patches/ openwrt/package/network/config/firewall4/patches/
rsync -a --no-o --no-g --progress ../patches/fullcone/nftables/patches/ openwrt/package/network/utils/nftables/patches/
rsync -a --no-o --no-g --progress ../patches/fullcone/libnftnl/patches/ openwrt/package/libs/libnftnl/patches/
sed -i '/PKG_INSTALL:=/iPKG_FIXUP:=autoreconf' openwrt/package/libs/libnftnl/Makefile

# bbrv3
git clone --depth=1 --single-branch -b ${MY_VERSION} https://github.com/QiuSimons/YAOF.git yaof
cp -rf yaof/PATCH/kernel/bbr3/* openwrt/target/linux/generic/backport-6.12/
rm -rf yaof
