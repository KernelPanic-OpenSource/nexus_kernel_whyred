#!/bin/bash
#
# Script For Building Android Kernel By akira-vishal
#
KERNEL_DIR=$PWD
TANGGAL=$(date +"%F-%S")
DATE=$(date +"%m-%d-%y")
START=$(date +"%s")
DEVICE=WhyRed
DEFCONFIG=vendor/whyred_defconfig
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
#
export BRANCH
export PATH="/usr/local/clang/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/clang/lib:$LD_LIBRARY_PATH"
#
# use ccache
export USE_CCACHE=1
#
#ccache variables
export CCACHE_DIR="$HOME/.ccache"
export CC="ccache clang"
export CXX="ccache clang++"
export PATH="/usr/lib/ccache:$PATH"
#
#Export ARCH <arm, arm64, x86, x86_64>
export ARCH=arm64
#
#Export SUBARCH <arm, arm64, x86, x86_64>
export SUBARCH=arm64
#
#Set kernal name
export LOCALVERSION=-X3
#Export Username
export KBUILD_BUILD_USER=VISHAL
#Export Machine name
export KBUILD_BUILD_HOST=AKIRA
#
function checker() {
    if [ -f $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb ]
       then
        echo -e "\e[1;32mCloning dependencies\e[0m"
        cd /usr/local && git clone https://github.com/kdrag0n/proton-clang.git --depth=1 clang
        echo -e "\e[1;32mCloning AnyKernel3\e[0m"
        cd && git clone https://github.com/akira-vishal/AnyKernel3.git --depth=1 AnyKernel
        echo -e "\e[1;32mDone!\e[0m"
        cd $HOME && cd $KERNEL_DIR
        zipper
       else
        echo -e "\e[1;32mBuild failed\e[0m"
    fi
}
#
function zipper() {
    rm -f $HOME/AnyKernel/Image.gz*
    rm -f $HOME/AnyKernel/zImage*
    rm -f $HOME/AnyKernel/dtb*
    echo -e "\e[1;32mTime To ZIP Up!\e[0m"
    cp $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb $HOME/AnyKernel
    cd $HOME/AnyKernel || exit 1
    zip -r9 neXus-X1_${DEVICE}-KERNEL-4.19-${TANGGAL}.zip *
    cd $HOME && cd $KERNEL_DIR
    END=$(date +"%s")
    DIFF=$(($END - $START))
    echo -e "\e[1;32mBuild Completed Succesfully\e[0m"
    echo -e "\e[1;32mBuild took : $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s).\e[0m"
}
#
function compiler() {
    rm -rf $KERNEL_DIR/out
    echo -e "\e[1;32mBuilding Kernel\e[0m"
    make O=out clean && make O=out mrproper
    make O=out ARCH=arm64 ${DEFCONFIG}
    make -j$(nproc --all) O=out \
                          ARCH=arm64 \
			  CC="clang" \
			  CROSS_COMPILE="aarch64-linux-gnu-" \
			  CROSS_COMPILE_ARM32="arm-linux-gnueabi-"
}
compiler
checker
