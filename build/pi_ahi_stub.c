/*
 * pi_ahi_stub.c — inert replacement for platforms/amiga/ahi/pi_ahi.c
 *
 * The real file implements Amiga AHI audio and needs alsa/asoundlib.h. A
 * Macintosh SE build never uses AHI, so we substitute no-ops. See rtg_stub.c.
 */
#include <stdint.h>

void *ahi_timing_task(void *args) { (void)args; return 0; }
void pi_ahi_set_playback_rate(uint32_t rate) { (void)rate; }
uint32_t pi_ahi_init(char *dev) { (void)dev; return 0; }
void pi_ahi_shutdown(void) {}
void pi_ahi_do_cmd(uint32_t val) { (void)val; }
void handle_pi_ahi_write(uint32_t addr_, uint32_t val, uint8_t type) { (void)addr_; (void)val; (void)type; }
uint32_t handle_pi_ahi_read(uint32_t addr_, uint8_t type) { (void)addr_; (void)type; return 0; }
void print_ahi_sample_type(uint16_t type) { (void)type; }
int get_ahi_sample_size(uint16_t type) { (void)type; return 1; }
int get_ahi_channels(uint16_t type) { (void)type; return 1; }
void print_ahi_debugmsg(int val, int type) { (void)val; (void)type; }
