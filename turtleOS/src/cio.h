#ifndef CIO_H
#define CIO_H

#include "stddef.h"
#include <stdint.h>

#define VGA_WIDTH 80
#define VGA_HEIGHT 20

void initialize_video_memory();
void clean_terminal();
void set_text_color(char new_colour);
void print_str(const char *str);

#endif