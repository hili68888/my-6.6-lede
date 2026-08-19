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
echo "CONFIG_TARGET_ipq60xx_generic_DEVICE_cmiot_ax18=y" >> .config

# 3. 自动注入中文 LuCI 网页后台系统
echo "CONFIG_PACKAGE_luci=y" >> .config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> .config

# 4. 【网络网络加速与常用工具】
echo "CONFIG_PACKAGE_luci-app-upnp=y" >> .config           # 通用即插即用（玩游戏、P2P 下载必备，自动映射端口）
echo "CONFIG_PACKAGE_luci-app-ddns=y" >> .config           # 动态域名解析（配合外网访问路由器）

# 5. LED 灯光高级控制
echo "CONFIG_PACKAGE_luci-app-ledtrig-system=y" >> .config   # 基础 LED 触发器控制面板（核心地基）
echo "CONFIG_PACKAGE_kmod-leds-gpio=y" >> .config           # 确保高通硬路由的 GPIO 灯光底层驱动被编译

# 6. 【高级运维与精美主题】
echo "CONFIG_PACKAGE_luci-app-ttyd=y" >> .config           # 网页版终端（刷好后无需 PuTTY，直接在浏览器里敲 SSH 命令）
echo "CONFIG_PACKAGE_luci-app-fileassistant=y" >> .config          # 图形化文件助手 fileassistant

# 彻底移除高通无线驱动及所有无线管理组件（打造纯有线固件）
echo "CONFIG_PACKAGE_kmod-ath11k=n" >> .config
echo "CONFIG_PACKAGE_kmod-ath11k-ahb=n" >> .config
echo "CONFIG_PACKAGE_wpad-openssl=n" >> .config


# ==================== 【终极网络代理依赖全家桶（通杀所有代理插件）】 ====================

# 1. 核心网络控制、流量劫持与内核模块（PassWall/OpenClash/SSR+ 共同地基）
echo "CONFIG_PACKAGE_bash=y" >> .config
echo "CONFIG_PACKAGE_curl=y" >> .config
echo "CONFIG_PACKAGE_ca-bundle=y" >> .config              # 补齐全局根证书
echo "CONFIG_PACKAGE_ipset=y" >> .config
echo "CONFIG_PACKAGE_ip-full=y" >> .config
echo "CONFIG_PACKAGE_coreutils-nohup=y" >> .config        # OpenClash 守护进程必备
echo "CONFIG_PACKAGE_kmod-tun=y" >> .config               # TUN 模式虚拟网卡驱动
echo "CONFIG_PACKAGE_libcap=y" >> .config
echo "CONFIG_PACKAGE_libcap-bin=y" >> .config
echo "CONFIG_PACKAGE_unzip=y" >> .config                  # 核心内核解压必备

# 2. 现代防火墙流量转发规则（适配当前 Linux 内核）
echo "CONFIG_PACKAGE_iptables-mod-tproxy=y" >> .config    # 经典 tproxy 透明代理
echo "CONFIG_PACKAGE_iptables-mod-extra=y" >> .config
echo "CONFIG_PACKAGE_kmod-ipt-tproxy=y" >> .config
echo "CONFIG_PACKAGE_kmod-nft-tproxy=y" >> .config       # 现代 nftables 劫持（新版 PassWall2/OpenClash 核心依赖）
echo "CONFIG_PACKAGE_kmod-nft-socket=y" >> .config       # Socket 匹配组件

# 3. 高级脚本解析器与语言支持（OpenClash 覆写规则与配置文件硬依赖）
echo "CONFIG_PACKAGE_ruby=y" >> .config                   # 规则覆写核心引擎
echo "CONFIG_PACKAGE_ruby-yaml=y" >> .config              # YAML 配置文件解析

# 4. 全功能高级 DNS 分流环境（规避精简版导致的运行崩溃）
# 彻底在默认模板中剔除精简版 dnsmasq，换成 full 完整版
sed -i 's/CONFIG_PACKAGE_dnsmasq=y/# CONFIG_PACKAGE_dnsmasq is not set/g' .config
echo "CONFIG_PACKAGE_dnsmasq-full=y" >> .config
echo "CONFIG_PACKAGE_unbound=y" >> .config                # 高级网络本地缓存与分流


# 修改 ttyd 默认免密登录
sed -i "s/option command '\/bin\/login'/option command '\/bin\/login -f root'/g" feeds/packages/utils/ttyd/files/ttyd.config
