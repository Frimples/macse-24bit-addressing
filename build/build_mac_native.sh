#!/bin/bash
# build_mac_native.sh — build the patched emulator ON the Raspberry Pi, with the
# Pi's own toolchain. Use this if a cross-compiled binary complains about
# glibc / GLIBCXX versions -- a native build always matches your distro.
#
#   cd pistorm-macintosh
#   git apply /path/to/patches/24bit_patch.diff
#   cp /path/to/build/*.c /path/to/build/build_mac_native.sh .
#   bash build_mac_native.sh
#
# Differences vs. the stock Makefile:
#   * uses the SYSTEM compiler (gcc/g++), not a cross-toolchain
#   * Amiga RTG / ALSA AHI / Pi-VC pistorm-dev replaced by inert stubs, so no
#     raylib, libasound or /opt/vc headers are required
#   * produces a STATIC binary by default (no glibc version dependency)
#
# Set STATIC=0 for a dynamic binary.
set -e
cd "$(dirname "$0")"

CC=${CC:-gcc}
CXX=${CXX:-g++}
STATIC=${STATIC:-1}

case "$(uname -m)" in
  armv7l|armv6l) ARCHFLAGS="-march=armv8-a -mfpu=neon-fp-armv8 -mfloat-abi=hard" ;;
  aarch64)       ARCHFLAGS="" ;;
  *)             ARCHFLAGS="" ;;
esac

WARN="-Wall -Wextra -pedantic"
DEFS="-D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE"
CFLAGS="$WARN -O3 $ARCHFLAGS $DEFS -I. -I./raylib"
OUT=emulator_mac_native

SRCS="emulator.c memory_mapped.c config_file/config_file.c config_file/rominfo.c \
input/input.c gpio/ps_protocol.c platforms/platforms.c \
platforms/amiga/amiga-autoconf.c platforms/amiga/amiga-platform.c \
platforms/amiga/amiga-registers.c platforms/amiga/amiga-interrupts.c \
platforms/mac68k/mac68k-platform.c platforms/dummy/dummy-platform.c \
platforms/dummy/dummy-registers.c platforms/amiga/Gayle.c \
platforms/amiga/hunk-reloc.c platforms/amiga/cdtv-dmac.c \
platforms/amiga/rtg/rtg.c platforms/amiga/rtg/rtg-gfx.c \
platforms/amiga/piscsi/piscsi.c pi_ahi_stub.c \
pistorm_dev_stub.c platforms/amiga/net/pi-net.c \
platforms/shared/rtc.c platforms/shared/common.c rtg_stub.c \
m68kcpu.c m68kdasm.c softfloat/softfloat.c softfloat/softfloat_fpsp.c m68kops.c"

echo "== host: $(uname -m)  compiler: $($CC -dumpversion)  static=$STATIC =="
echo "== generating m68kops.c =="
$CC -o m68kmake m68kmake.c
./m68kmake . m68k_in.c

rm -rf build_native && mkdir -p build_native
echo "== compiling =="
OBJS=""
for s in $SRCS; do
    o="build_native/$(echo "$s" | tr '/' '_' | sed 's/\.c$/.o/')"
    $CC $CFLAGS -c "$s" -o "$o" 2>>build_native_errors.log || { echo "FAILED: $s (see build_native_errors.log)"; exit 1; }
    OBJS="$OBJS $o"
done

echo "== compiling a314 (C++) =="
$CXX $CFLAGS -c a314/a314.cc -o build_native/a314.o 2>>build_native_errors.log || { echo "FAILED: a314"; exit 1; }
OBJS="$OBJS build_native/a314.o"

echo "== linking =="
if [ "$STATIC" = "1" ]; then
    $CC -static -o $OUT $OBJS -O3 -pthread -lm -lstdc++ 2>>build_native_errors.log || { echo "LINK FAILED"; exit 1; }
else
    $CC -o $OUT $OBJS -O3 -pthread -lm -lstdc++ 2>>build_native_errors.log || { echo "LINK FAILED"; exit 1; }
fi

strip $OUT 2>/dev/null || true
file $OUT
echo "OK: $OUT  ($(du -h $OUT | cut -f1))"
echo
echo "Run with:  sudo ./$OUT"
