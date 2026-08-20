#!/bin/bash
#
# https://github.com
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 1. 【优雅切换 6.6】利用大雕和 LibWrt 源码原生的 KERNEL_TESTING 机制完美切换至 6.6
# 这样系统在打补丁时会使用最安全的官方原生方案，不会因为强行覆盖导致 drivers/remoteproc 报错
if [ -f "target/linux/qualcommax/Makefile" ]; then
    sed -i 's/KERNEL_PATCHVER:=6.12/KERNEL_PATCHVER:=$(KERNEL_TESTING_PATCHVER)/g' target/linux/qualcommax/Makefile
fi

# 1.5 【核心报错修复】既然编译纯有线固件，直接强行删除引发冲突的高通无线内核补丁
if [ -f "target/linux/qualcommax/patches-6.6/0113-remoteproc-qcom-Add-secure-PIL-support.patch" ]; then
    rm -f target/linux/qualcommax/patches-6.6/0113-remoteproc-qcom-Add-secure-PIL-support.patch
fi

# 2. 自动将基础组件中的 dnsmasq 替换为 dnsmasq-full，从源头规避包冲突
find include/ target/ -name "Makefile" -o -name "*.mk" | xargs sed -i 's/\bdnsmasq\b/dnsmasq-full/g' 2>/dev/null
