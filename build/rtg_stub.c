/*
 * rtg_stub.c — inert replacement for platforms/amiga/rtg/rtg-output-raylib.c
 *
 * The real file pulls in raylib + Raspberry Pi dispmanx/VCHIQ headers, which
 * are ONLY needed for the Amiga RTG (host-side graphics) feature. A Macintosh
 * SE build does not use RTG, so we substitute no-op implementations of the same
 * exported symbols + globals. This keeps the build dependency-free (no raylib /
 * /opt/vc) while leaving the emulator's Mac path fully intact.
 *
 * Used ONLY by the Mac-focused build (see build_mac_armhf.sh). Upstream Amiga
 * Makefile is untouched.
 */
#include <stdint.h>

/* --- globals normally defined by rtg-output-raylib.c --- */
uint8_t  rtg_on = 0, emulator_exiting = 0, rtg_output_in_vblank = 0, rtg_dpms = 0;
uint32_t cur_rtg_frame = 0;

/* --- output/display entry points --- */
void rtg_update_screen(void) {}
void rtg_scale_output(uint16_t width, uint16_t height) { (void)width; (void)height; }
void *rtgThread(void *args) { (void)args; return 0; }
void rtg_set_screen_width(uint32_t width) { (void)width; }
void rtg_set_screen_height(uint32_t height) { (void)height; }
void rtg_set_clut_entry(uint8_t index, uint32_t xrgb) { (void)index; (void)xrgb; }
void rtg_init_display(void) {}
void rtg_shutdown_display(void) {}
void rtg_show_clut_cursor(uint8_t show) { (void)show; }
void rtg_set_clut_cursor(uint8_t *bmp, uint32_t *pal, int16_t offs_x, int16_t offs_y,
                         uint16_t w, uint16_t h, uint8_t mask_color) {
    (void)bmp; (void)pal; (void)offs_x; (void)offs_y; (void)w; (void)h; (void)mask_color;
}
void rtg_enable_mouse_cursor(uint8_t enable) { (void)enable; }
void rtg_set_mouse_cursor_pos(int16_t x, int16_t y) { (void)x; (void)y; }
void rtg_set_cursor_clut_entry(uint8_t r, uint8_t g, uint8_t b, uint8_t idx) {
    (void)r; (void)g; (void)b; (void)idx;
}
void rtg_set_mouse_cursor_image(uint8_t *src, uint8_t w, uint8_t h) {
    (void)src; (void)w; (void)h;
}
