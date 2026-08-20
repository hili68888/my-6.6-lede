#!/bin/bash
#
# https://github.com
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 1. 【优雅切换 6.6】利用大雕和 LibWrt 源码原生的 KERNEL_TESTING 机制完美切换至 6.6
if [ -f "target/linux/qualcommax/Makefile" ]; then
    sed -i 's/KERNEL_PATCHVER:=6.12/KERNEL_PATCHVER:=$(KERNEL_TESTING_PATCHVER)/g' target/linux/qualcommax/Makefile
fi

# 1.5 【核心报错修复】既然编译纯有线固件，直接强行删除引发冲突的高通无线内核补丁
if [ -f "target/linux/qualcommax/patches-6.6/0113-remoteproc-qcom-Add-secure-PIL-support.patch" ]; then
    rm -f target/linux/qualcommax/patches-6.6/0113-remoteproc-qcom-Add-secure-PIL-support.patch
fi

# 2. 自动将基础组件中的 dnsmasq 替换为 dnsmasq-full，从源头规避包冲突
find include/ target/ -name "Makefile" -o -name "*.mk" | xargs sed -i 's/\bdnsmasq\b/dnsmasq-full/g' 2>/dev/null


# =====================================================================
# 3. 【核心修复】强行向 .config 追加锁死高通 qualcommax 架构基础参数
# 防止被系统自带的 make defconfig 识别为“非法残缺配置”而重置为默认的 x86-64
# =====================================================================
echo 'CONFIG_TARGET_qualcommax=y' >> .config
echo 'CONFIG_TARGET_qualcommax_ipq60xx=y' >> .config
echo 'CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_cmiot_ax18=y' >> .config
echo 'CONFIG_TARGET_BOARD="qualcommax"' >> .config
echo 'CONFIG_TARGET_SUBTARGET="ipq60xx"' >> .config
echo 'CONFIG_TARGET_ARCH_PACKAGES="aarch64_cortex-a53"' >> .config
