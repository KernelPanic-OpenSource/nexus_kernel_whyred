#!/usr/bin/env bash
echo "Cloning dependencies"
git clone --depth=1 https://github.com/kdrag0n/proton-clang Clang
git clone --depth=1 https://github.com/akira-vishal/AnyKernel3.git AnyKernel
echo "Done"
KERNEL_DIR=$(pwd)
PATH="${PWD}/clang/bin:$PATH"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
DEVICE=WhyRed
DEFCONFIG=whyred-newcam_defconfig
CAMERA=NewCam
OVERCLOCK=NonOC
VERSION=X4
#Export variables
export LOCALVERSION="-X4"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/Clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64
export KBUILD_BUILD_HOST=circleci
export KBUILD_BUILD_USER="vishal"
# Check plox
function checker() {
    if ! [ -a "$IMAGE" ]; then
        zipper
        exit 1
    fi
}
# Zip plox
function zipper() {
    rm -f AnyKernel/Image.gz*
    rm -f AnyKernel/zImage*
    rm -f AnyKernel/dtb*
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
    cd AnyKernel || exit 1
    zip -r9 neXus-${VERSION}_${DEVICE}-${CAMERA}-${OVERCLOCK}-KERNEL-${TANGGAL}.zip *
    cd ..
}
# Push kernel to group
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot1373659015:AAHYlK0kyimFra5qcAL6mV2jsCCNAT26nys/sendDocument" \
        -F chat_id="1322257045" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Xiaomi Redmi Note 5/5pro (whyred)</b>"
}
# Compile plox
function compiler() {
    make O=out ARCH=arm64 ${DEFCONFIG}
    make -j$(nproc --all) O=out \
                          ARCH=arm64 \
			  CC=clang \
			  CROSS_COMPILE=aarch64-linux-gnu- \
			  CROSS_COMPILE_ARM32=arm-linux-gnueabi-
}
compiler
checker
END=$(date +"%s")
DIFF=$(($END - $START))
push

