#!/bin/bash

function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    find package/ -follow -name $pkg -not -path "package/custom/*" | xargs -rt rm -rf
    git clone --depth=1 --single-branch $1
    mv $2 package/custom/
    rm -rf $repo
}

function merge_package2(){
    pkg=`echo $1 | rev | cut -d'/' -f 1 | rev`
    find package/ -follow -name $pkg -not -path "package/custom/*" | xargs -rt rm -rf
    mv $1 package/custom/
}

function merge_feed(){
    if [ ! -d "feed/$1" ]; then
        # echo >> feeds.conf.default
        # echo "src-git $1 $2" >> feeds.conf.default
        sed -i "1isrc-git $1 $2" feeds.conf.default
    fi
    # ./scripts/feeds update $1
    # ./scripts/feeds install -a -p $1
}

rm -rf openwrt/package/custom/
mkdir -p openwrt/package/custom/

# add luci-app-diskman
(cd openwrt && {
    merge_package https://github.com/lisaac/luci-app-diskman luci-app-diskman/applications/luci-app-diskman

    mkdir -p package/parted
    wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/parted/Makefile
})
cat >> ../configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_smartmontools=y
EOL

# add nft-fullcone
(cd openwrt && {
    merge_package https://github.com/friendlyarm/nft-fullcone nft-fullcone
    echo "CONFIG_PACKAGE_nft-fullcone=y" >> ../../configs/rockchip/01-nanopi
})

# add luci-theme-argon
(cd openwrt/package && {
    [ -d luci-theme-argon ] && rm -rf luci-theme-argon
    git clone https://github.com/jerrykuku/luci-theme-argon.git --depth 1 -b master
})
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> ../configs/rockchip/01-nanopi
sed -i -e 's/function init_theme/function old_init_theme/g' openwrt/target/linux/rockchip/armv8/base-files/root/setup.sh
cat > /tmp/appendtext.txt <<EOL
function init_theme() {
    if uci get luci.themes.Argon >/dev/null 2>&1; then
        uci set luci.main.mediaurlbase="/luci-static/argon"
        uci commit luci
    fi
}
EOL
sed -i -e '/boardname=/r /tmp/appendtext.txt' openwrt/target/linux/rockchip/armv8/base-files/root/setup.sh


(cd openwrt && merge_feed PWpackages "https://github.com/Openwrt-Passwall/openwrt-passwall-packages")
(cd openwrt && merge_feed PWluci "https://github.com/Openwrt-Passwall/openwrt-passwall;main")

#add ddns-scripts_aliyun
(
    cd openwrt && {
        git clone --depth=1 --single-branch -b openwrt-${MY_VERSION} https://github.com/immortalwrt/packages.git im_packages
        merge_package2 im_packages/net/ddns-scripts
        rm -rf im_packages
    }
)

(
    cd openwrt && {
        git clone --depth=1 --single-branch https://github.com/coolsnowwolf/lede.git lean_openwrt
        merge_package2 lean_openwrt/package/lean/cpufreq
        rm -rf lean_openwrt
    }
)

(
    cd openwrt && {
        git clone --depth=1 --single-branch -b openwrt-${MY_VERSION} https://github.com/coolsnowwolf/luci.git lean_luci

        merge_package2 lean_luci/applications/luci-app-cpufreq
        sed -i 's/include ..\/..\/luci.mk/include $(TOPDIR)\/feeds\/luci\/luci.mk/' package/custom/luci-app-cpufreq/Makefile
        echo "CONFIG_PACKAGE_luci-app-cpufreq=y" >> ../../configs/rockchip/01-nanopi

        merge_package2 lean_luci/applications/luci-app-openvpn-server
        sed -i 's/include ..\/..\/luci.mk/include $(TOPDIR)\/feeds\/luci\/luci.mk/' package/custom/luci-app-openvpn-server/Makefile
        echo "CONFIG_PACKAGE_luci-app-openvpn-server=y" >> ../../configs/rockchip/01-nanopi

        rm -rf lean_luci
    }
)

# add luci-app-wechatpush
(cd openwrt && {
    merge_package https://github.com/tty228/luci-app-wechatpush luci-app-wechatpush
    echo "CONFIG_PACKAGE_luci-app-wechatpush=y" >> ../../configs/rockchip/01-nanopi
})

#add luci-app-netdata
(
    cd openwrt && {
        git clone --depth=1 --single-branch https://github.com/sbwml/openwrt_pkgs.git sbwml_pkgs

        merge_package2 sbwml_pkgs/luci-app-netdata
        #added in 04-utils
        #echo "CONFIG_PACKAGE_luci-app-netdata=y" >> ../../configs/rockchip/01-nanopi

        # merge_package2 sbwml_pkgs/luci-app-cpufreq
        # echo "CONFIG_PACKAGE_luci-app-cpufreq=y" >> ../../configs/rockchip/01-nanopi

        rm -rf sbwml_pkgs
    }
)

(
    cd openwrt && {
        ./scripts/feeds update -a
        ./scripts/feeds install -a
    }
)

# 2025.10.17 rust disable download
sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' openwrt/feeds/packages/lang/rust/Makefile

# go lang version 2025.10.16
(
    cd openwrt && {
        rm -rf feeds/packages/lang/golang
        git clone https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang
    }
)

# fullcone patch
(
    cd openwrt/feeds/luci && {
        patch -p1 < ../../../../patches/fullcone/luci/0001-luci-add-option-for-fullcone-nat.patch
    }
)
