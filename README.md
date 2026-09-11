# macse-24bit-addressing

A small patch for the **PiStorm Macintosh SE emulator**
([Frimples/pistorm-macintosh](https://github.com/Frimples/pistorm-macintosh),
a Musashi 68k fork) that makes **68020/68030-class CPU cores usable on the
Mac SE** by giving them a **24-bit address bus**.

## The problem

Classic Mac OS (and the SE ROM) are **not 32-bit clean** — they store flags in
the high byte of pointers and handles, and rely on the CPU wrapping addresses
at 24 bits. That's why only 24-bit-addressing CPUs work on the SE:

| CPU | Address bus | SE |
|---|---|---|
| 68000 / 68010 / 68EC020 | 24-bit | ✅ works |
| 68020 / 68030 / 68EC030 | 32-bit | ❌ grey screen, no boot |
| 68040 | 32-bit (cannot do 24-bit) | ❌ never |

Musashi implements this with `CPU_ADDRESS_MASK`, set per CPU type in
`m68k_set_cpu_type()`, and applied on **every** memory access:

```c
#define ADDRESS_68K(A) ((A) & CPU_ADDRESS_MASK)

m68kcpu.c:791:  CPU_ADDRESS_MASK = 0x00ffffff;   // 68000 / 68010 / 68EC020
m68kcpu.c:850:  CPU_ADDRESS_MASK = 0xffffffff;   // 68020 / 68030 / 68EC030
```

## The patch

`patches/24bit_patch.diff` — 4 files, 117 lines:

| File | Change |
|---|---|
| `m68kcpu.c` | renames the real body to `m68k_set_cpu_type_inner()`; adds global `m68k_force_24bit_addressing` (default **1**) and a public `m68k_set_cpu_type()` wrapper that clamps the mask to `0x00FFFFFF` |
| `m68k.h` | declares the global |
| `platforms/mac68k/mac68k-platform.c` | adds a `force24bit` config option |
| `platforms/macse/default.cfg` | documents it |

Result: an 020/030-class core behaves like a 24-bit-addressing CPU —
essentially a **"68EC020 with 030 instructions"**.

```bash
cd pistorm-macintosh
git apply /path/to/patches/24bit_patch.diff
```

Default is **ON**. To restore normal 32-bit behaviour:

```
force24bit 0
```

## Measured cost

Benchmarked standalone on an aarch64 Raspberry Pi (real Musashi 68000 core):

| | Mips |
|---|---|
| 68030, normal 32-bit mask | 165.6 |
| 68030, forced 24-bit mask | 163.4 |
| **cost** | **~1.3%** |

Essentially free: `ADDRESS_68K()` already performs the `AND` — this just makes
it operate on a 24-bit constant instead of a no-op `& 0xFFFFFFFF`.

## Verification performed

1. **Functional** — a standalone test linking the real patched core:
   ```
   force24bit=1:  68000/68010/68EC020/68020/68030/68EC030 -> 0x00FFFFFF (24-bit)
   force24bit=0:  68000/68010/68EC020 -> 0x00FFFFFF; 020/030/68EC030 -> 0xFFFFFFFF
   ```
2. **Build** — the full emulator cross-compiles and links for **armhf** (the
   PiStorm target) via `build/build_mac_armhf.sh`. Symbols
   `m68k_force_24bit_addressing`, `m68k_set_cpu_type`,
   `m68k_set_cpu_type_inner` present.
3. **Runs** — the static armhf binary starts on a 32-bit-compat kernel (stops
   at `/dev/mem`, i.e. it needs root + real GPIO, as expected).

## Not verified

**No boot test on real Mac SE / PiStorm hardware.** Forcing a 24-bit address
mask is likely **necessary but not sufficient**: a 68020/030 also pushes
**different exception stack frames** than the 68000 the SE ROM expects. That is
the probable next failure — flag it, don't assume success.

## Building a Mac-focused emulator

`build/build_mac_armhf.sh` cross-compiles the emulator for **32-bit armhf**
(what the PiStorm requires per the fork's README) without the dependencies that
only the Amiga paths need:

| Stub | Replaces | Needs |
|---|---|---|
| `rtg_stub.c` | `platforms/amiga/rtg/rtg-output-raylib.c` | raylib + `/opt/vc` |
| `pi_ahi_stub.c` | `platforms/amiga/ahi/pi_ahi.c` | ALSA |
| `pistorm_dev_stub.c` | `platforms/amiga/pistorm-dev/pistorm-dev.c` | Pi VCHIQ headers |

None affect the Macintosh code path. The upstream `Makefile` is untouched.

```bash
cd pistorm-macintosh
git apply /path/to/patches/24bit_patch.diff
cp /path/to/build/*.c /path/to/build/build_mac_armhf.sh .
bash build_mac_armhf.sh          # -> emulator_mac_armhf (armhf)
```

## Related

* [macse-virtual-floppy](https://github.com/Frimples/macse-virtual-floppy) —
  a virtual floppy driver that installs into the SE ROM's old easter-egg space.
  The build stubs here are shared with that project.

## License

MIT — see [LICENSE](LICENSE). The ROM itself is not distributed here.
