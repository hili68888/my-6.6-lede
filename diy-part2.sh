#!/bin/bash
#
# https://github.com
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 1. 【通用强改 6.6】不管当前默认是 6.12 还是其他任何版本，一律强制清洗并锁死为 6.6
if [ -f "target/linux/qualcommax/Makefile" ]; then
    sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.6/g' target/linux/qualcommax/Makefile
fi

# 2. 自动将基础组件中的 dnsmasq 替换为 dnsmasq-full，从源头规避包冲突
find include/ target/ -name "Makefile" -o -name "*.mk" | xargs sed -i 's/\bdnsmasq\b/dnsmasq-full/g' 2>/dev/null

# 3. 注入你的定制机型与全部终极网络功能组件
cat >> .config <<EOF
# 核心机型锁定（适配大雕最新重构的 qualcommax 架构）
CONFIG_TARGET_qualcommax=y
CONFIG_TARGET_qualcommax_ipq60xx=y
CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_cmiot_ax18=y

# 自动注入中文 LuCI 网页后台系统与 DNSMasq 后台管理器
CONFIG_PACKAGE_luci=y
CONFIG_LUCI_LANG_zh_Hans=y
CONFIG_PACKAGE_luci-app-dnsmasq=y

# 【网络加速与常用工具】
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-app-ddns=y

# LED 灯光高级控制
CONFIG_PACKAGE_luci-app-ledtrig-system=y
CONFIG_PACKAGE_kmod-leds-gpio=y

# 【高级运维与精美主题】
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-fileassistant=y
CONFIG_PACKAGE_luci-i18n-fileassistant-zh-cn=y

# 彻底移除无线组件（打造绝对纯净的有线主/旁路由固件）
CONFIG_PACKAGE_kmod-ath11k=n
CONFIG_PACKAGE_kmod-ath11k-ahb=n
CONFIG_PACKAGE_wpad-openssl=n

# ==================== 【终极网络代理依赖全家桶（轻量化纯净版）】 ====================
# 核心底层控制与传输
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_ca-bundle=y
CONFIG_PACKAGE_ipset=y
CONFIG_PACKAGE_ip-full=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_libcap=y
CONFIG_PACKAGE_unzip=y
CONFIG_PACKAGE_coreutils-nohup=y

# 密码学与跑满带宽解密加速
CONFIG_PACKAGE_libopenssl-conf=y
CONFIG_PACKAGE_libopenssl-legacy=y
CONFIG_PACKAGE_ipsec-tools=y

# 现代 nftables 防火墙流量转发规则（全面适配原生防火墙，加速分流）
CONFIG_PACKAGE_kmod-nft-tproxy=y
CONFIG_PACKAGE_kmod-nft-socket=y
CONFIG_PACKAGE_kmod-nft-bridge=y
CONFIG_PACKAGE_kmod-nft-nat=y

# 高性能 DNS 分流环境（保留唯一核心，极致轻量）
CONFIG_PACKAGE_dnsmasq-full=y

# 确保激活高通 NSS 硬件转发加速（包含网桥、拨号、VLAN 流量全硬件转发）
CONFIG_PACKAGE_kmod-qca-nss-ecm=y
CONFIG_PACKAGE_kmod-qca-nss-drv-bridge-mgr=y
CONFIG_PACKAGE_kmod-qca-nss-drv-vlan=y
EOF
