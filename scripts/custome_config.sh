#!/bin/bash

sed -i -e '555i\CONFIG_PACKAGE_tcpdump=y' ../configs/rockchip/01-nanopi
sed -i -e '513i\CONFIG_PACKAGE_mosquitto-client-ssl=y' ../configs/rockchip/01-nanopi
sed -i -e '460i\CONFIG_PACKAGE_luci-app-passwall=y' ../configs/rockchip/01-nanopi
sed -i -e '460a\CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Libev_Client=n' ../configs/rockchip/01-nanopi
sed -i -e '460a\CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Libev_Server=n' ../configs/rockchip/01-nanopi
sed -i -e '460a\CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_Libev_Client=n' ../configs/rockchip/01-nanopi
sed -i -e '460a\CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus=n' ../configs/rockchip/01-nanopi
sed -i -e '460a\CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray_Plugin=n' ../configs/rockchip/01-nanopi
sed -i -e '243i\CONFIG_PACKAGE_keepalived=y' ../configs/rockchip/01-nanopi
sed -i -e '184i\CONFIG_PACKAGE_ddns-scripts-cloudflare=y' ../configs/rockchip/01-nanopi
sed -i -e '184i\CONFIG_PACKAGE_ddns-scripts-godaddy=y' ../configs/rockchip/01-nanopi
sed -i -e '184i\CONFIG_PACKAGE_ddns-scripts-aliyun=y' ../configs/rockchip/01-nanopi
sed -i -e '184i\CONFIG_PACKAGE_ddns-scripts-dnspod=y' ../configs/rockchip/01-nanopi
sed -i '/CONFIG_PACKAGE_luci-app-aria2=y/d' ../configs/rockchip/01-nanopi
sed -i '/CONFIG_PACKAGE_vsftpd=y/d' ../configs/rockchip/01-nanopi
# after 25.12 no more nft-qos
sed -i '/CONFIG_PACKAGE_luci-app-nft-qos=y/d' ../configs/rockchip/01-nanopi
sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/g' ../configs/rockchip/01-nanopi
# append kernel size for backup files
sed -i 's/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=128/g' ../configs/rockchip/01-nanopi

# sed -i -e '/CONFIG_MAKE_TOOLCHAIN=y/d' ../configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_IB=y/# CONFIG_IB is not set/g' ../configs/rockchip/01-nanopi
sed -i -e 's/CONFIG_SDK=y/# CONFIG_SDK is not set/g' ../configs/rockchip/01-nanopi
echo "CONFIG_CCACHE=y" >> ../configs/rockchip/01-nanopi

sed -i 's/=y/=n/g' ../configs/rockchip/02-luci_lang
sed -i 's/CONFIG_LUCI_LANG_en=n/CONFIG_LUCI_LANG_en=y/' ../configs/rockchip/02-luci_lang
sed -i 's/CONFIG_LUCI_LANG_zh_Hans=n/CONFIG_LUCI_LANG_zh_Hans=y/' ../configs/rockchip/02-luci_lang

## ugly fix of the read-only issue
#sed -i '3 i sed -i "/^exit.*/i\\/bin\\/mount -o remount,rw /" /etc/rc.local' `find openwrt/package -type f -path '*/default-settings/files/*-default-settings'`
