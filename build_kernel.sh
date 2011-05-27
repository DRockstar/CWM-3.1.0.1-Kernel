#/bin/bash

# This was modified from the EpicCM/nullghost repos build scripts by DRockstar.
# by default, the kernel build will use ${TARGET}_defconfig, in this case, Clean.Kernel_defconfig

BUILD_KERNEL=y
CLEAN=n
MKZIP='7z -mx9 -mmt=1 a "$OUTFILE" .'
DEFCONFIG=y
PRODUCE_TAR=n
PRODUCE_ZIP=y
TARGET="cwm"
THREADS=$(expr 1 + $(grep processor /proc/cpuinfo | wc -l))
VERSION=$(date '+%Y-%m-%d-%H.%M.%S')
PROJECT_NAME=SPH-D700
HW_BOARD_REV="03"
TARGET_LOCALE="vzw"
TOOLCHAIN=`pwd`/../arm-2009q3/bin
TOOLCHAIN_PREFIX=arm-none-linux-gnueabi-
CROSS_COMPILE="$TOOLCHAIN/$TOOLCHAIN_PREFIX"
KERNEL_BUILD_DIR=`pwd`/Kernel
ANDROID_OUT_DIR=`pwd`/Android/out/target/product/SPH-D700

export PRJROOT=$PWD
export PROJECT_NAME
export HW_BOARD_REV
export LD_LIBRARY_PATH=.:${TOOLCHAIN}/../lib

SHOW_HELP()
{
	echo
	echo "Usage options for build_kernel.sh:"
	echo "-c : Run 'make clean'"
	echo "-d : Use specified config."
	echo "     For example, use -d myconfig to 'make myconfig_defconfig'"
	echo "-h : Print this help."
	echo "-j : Use a specified number of threads to build. (Autodetects by default.)"
	echo "     For example, use -j4 to make with 4 threads."
	echo "-t : Produce tar file suitable for flashing with Odin."
	echo "-z : Produce zip file suitable for flashing via Recovery."
	echo
	exit 1
}

# Get values from Args
set -- $(getopt cd:hj:tz "$@")
while [ $# -gt 0 ]
do
	case "$1" in
	(-c) CLEAN=y;;
	(-d) DEFCONFIG=y; TARGET="$2"; shift;;
	(-h) SHOW_HELP;;
	(-j) THREADS=$2; shift;;
	(-t) PRODUCE_TAR=y;;
	(-z) PRODUCE_ZIP=y;;
	(--) shift; break;;
	(-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
	(*) break;;
	esac
	shift
done

echo "************************************************************"
echo "* EXPORT VARIABLE		                            	 *"
echo "************************************************************"
echo "PRJROOT=$PRJROOT"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "HW_BOARD_REV=$HW_BOARD_REV"
echo "************************************************************"
echo "make clean    == "$CLEAN
echo "use defconfig == "$DEFCONFIG
echo "build target  == "$TARGET
echo "make threads  == "$THREADS
echo "build kernel  == "$BUILD_KERNEL
echo "create tar    == "$PRODUCE_TAR
echo "create zip    == "$PRODUCE_ZIP
echo

pushd $KERNEL_BUILD_DIR
export KDIR=`pwd`

if [ "$CLEAN" = "y" ] ; then
	echo "Cleaning source directory." && echo ""
	make -j"$THREADS" ARCH=arm clean
fi

if [ "$DEFCONFIG" = "y" -o ! -f ".config" ] ; then
	echo "Using default configuration for $TARGET" && echo ""
	make -j"$THREADS" ARCH=arm ${TARGET}_defconfig
fi

if [ "$BUILD_KERNEL" = "y" ] ; then
	T1=$(date +%s)
	echo "Beginning zImage compilation..." && echo ""
	make -j"$THREADS" ARCH=arm CROSS_COMPILE="$CROSS_COMPILE"
	T2=$(date +%s)
	echo "" && echo "Compilation took $(($T2 - $T1)) seconds." && echo ""
fi

echo "Cleaning initramfs files..."; echo
for file in cpio o cpio.lzma lzma.o cpio.gz gz.o cpio.bz2 bz2.o; do
	rm -f usr/initramfs_data.$file
done

popd

if [ "$PRODUCE_TAR" = y ] ; then
	echo "Generating $TARGET-$VERSION.tar for flashing with Odin" && echo ""
	tar c -C $KERNEL_BUILD_DIR/arch/arm/boot zImage >"$TARGET-$VERSION.tar"
fi

if [ "$PRODUCE_ZIP" = y ] ; then
	echo "Generating $TARGET-$VERSION.zip for flashing as update.zip" && echo ""
	rm -fr "$TARGET-$VERSION.zip"
	rm -f update/kernel/zImage
	cp $KERNEL_BUILD_DIR/arch/arm/boot/zImage update/kernel
	OUTFILE="$PWD/$TARGET-$VERSION.zip"
	pushd update
	eval "$MKZIP" >/dev/null 2>&1
	popd
fi

echo "All done!"

