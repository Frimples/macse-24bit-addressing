/*
 * pistorm_dev_stub.c — inert replacement for
 * platforms/amiga/pistorm-dev/pistorm-dev.c
 *
 * The real file reads Pi temperature/host strings via the Raspberry Pi VCHIQ
 * firmware interface (interface/vmcs_host/vc_vchi_gencmd.h), which is not
 * available in a plain cross-build and is Amiga-specific. A Macintosh SE build
 * does not use the PiStorm Amiga "pistorm-dev" Zorro-II device, so we stub it.
 */
#include <stdint.h>

static char pistorm_devcfg_filename[] = "default.cfg";

int32_t grab_amiga_string(uint32_t addr, uint8_t *dest, uint32_t str_max_len) {
    (void)addr; (void)dest; (void)str_max_len; return -1;
}
int32_t amiga_transfer_file(uint32_t addr, char *filename) {
    (void)addr; (void)filename; return -1;
}
char *get_pistorm_devcfg_filename(void) { return pistorm_devcfg_filename; }
void set_pistorm_devcfg_filename(char *filename) {
    (void)filename;   /* config reload not supported in this build */
}
void handle_pistorm_dev_write(uint32_t addr_, uint32_t val, uint8_t type) {
    (void)addr_; (void)val; (void)type;
}
uint32_t handle_pistorm_dev_read(uint32_t addr_, uint8_t type) {
    (void)addr_; (void)type; return 0;
}
