#!/bin/bash
# build_mac_armhf.sh — build the PATCHED PiStorm m68k emulator for the Mac SE,
# cross-compiled for 32-bit armhf (what the PiStorm actually requires).
#
# Changes vs. the stock Makefile:
#   * cross-compiler = arm-linux-gnueabihf-gcc / -g++
#   * Amiga RTG  ->  rtg_stub.c  (drops the raylib + /opt/vc dependency)
#   * includes the 24-bit addressing patch in m68kcpu.c/m68k.h
set -e
cd "$(dirname "$0")"

CC=arm-linux-gnueabihf-gcc
CXX=arm-linux-gnueabihf-g++
ARCHFLAGS="-march=armv8-a -mfpu=neon-fp-armv8 -mfloat-abi=hard"
WARN="-Wall -Wextra -pedantic"
DEFS="-D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE"
CFLAGS="$WARN -O3 $ARCHFLAGS $DEFS -I. -I./raylib"
OUT=emulator_mac_armhf

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

echo "== generating m68kops.c =="
gcc -o m68kmake m68kmake.c
./m68kmake . m68k_in.c

echo "== compiling (armhf) =="
OBJS=""
for s in $SRCS; do
    o="build_armhf/$(echo "$s" | tr '/' '_' | sed 's/\.c$/.o/')"
    mkdir -p "$(dirname "$o")"
    $CC $CFLAGS -c "$s" -o "$o" 2>>build_armhf_errors.log || { echo "FAILED: $s"; exit 1; }
    OBJS="$OBJS $o"
done

echo "== compiling a314 (C++) =="
$CXX $CFLAGS -c a314/a314.cc -o build_armhf/a314.o 2>>build_armhf_errors.log || { echo "FAILED: a314"; exit 1; }
OBJS="$OBJS build_armhf/a314.o"

echo "== linking =="
$CC -o $OUT $OBJS -O3 -pthread -lm -lstdc++ 2>>build_armhf_errors.log || { echo "LINK FAILED"; exit 1; }
file $OUT
echo "OK: $OUT"
