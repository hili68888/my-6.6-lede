#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

#!/bin/bash

# 1. 强行将全平台内核版本修改并锁定为 6.6
find ./target/linux/ -name "Makefile" | xargs sed -i 's/KERNEL_PATCHVER:=6.12/KERNEL_PATCHVER:=6.6/g' 2>/dev/null
find ./target/linux/ -name "Makefile" | xargs sed -i 's/KERNEL_PATCHVER:=6.1/KERNEL_PATCHVER:=6.6/g' 2>/dev/null

# 2. 精准锁定高通 IPQ60xx 平台和你的 CMIOT AX18 专属机型
echo "CONFIG_TARGET_ipq60xx=y" >> .config
echo "CONFIG_TARGET_ipq60xx_Generic=y" >> .config
echo "CONFIG_TARGET_ipq60xx_Generic_DEVICE_cmiot_ax18=y" >> .config

# 3. 自动注入中文 LuCI 网页后台系统
echo "CONFIG_PACKAGE_luci=y" >> .config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> .config

# 4. 【网络网络加速与常用工具】
echo "CONFIG_PACKAGE_luci-app-upnp=y" >> .config           # 通用即插即用（玩游戏、P2P 下载必备，自动映射端口）
echo "CONFIG_PACKAGE_luci-app-ddns=y" >> .config           # 动态域名解析（配合外网访问路由器）


# 6. 【高级运维与精美主题】
echo "CONFIG_PACKAGE_luci-app-ttyd=y" >> .config           # 网页版终端（刷好后无需 PuTTY，直接在浏览器里敲 SSH 命令）


# 彻底移除高通无线驱动及所有无线管理组件（打造纯有线固件）
echo "CONFIG_PACKAGE_kmod-ath11k=n" >> .config
echo "CONFIG_PACKAGE_kmod-ath11k-ahb=n" >> .config
echo "CONFIG_PACKAGE_wpad-openssl=n" >> .config

# 修改 ttyd 默认免密登录
sed -i "s/option command '\/bin\/login'/option command '\/bin\/login -f root'/g" feeds/packages/utils/ttyd/files/ttyd.config
