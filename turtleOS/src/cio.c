#include "cio.h"

unsigned short *video_memory;
char text_colour = 15;
unsigned short terminal_row = 0;
unsigned short terminal_column = 0;

void next_row()
{
    terminal_column = 0;
    terminal_row++;
}

void initialize_video_memory()
{
    // 0xB8000 is the VGA address.
    video_memory = (unsigned short *)(0xB8000);
}

void clean_terminal()
{
    for (int y = 0; y < VGA_HEIGHT; y++)
    {
        for (int x = 0; x < VGA_WIDTH; x++)
        {
            video_memory[y * VGA_WIDTH + x] = (text_colour << 8) | ' ';
        }
    }
}

void set_text_color(char new_colour)
{
    text_colour = new_colour;
}

void print_str(const char *str)
{
    // storing the total char length of the string
    unsigned long str_length = 0;

    while (str[str_length])
    {
        str_length++;
    }

    for (unsigned int i = 0; i < str_length; i++)
    {
        if (str[i] == '\n')
        {
            next_row();
            continue;
        }

        unsigned short currentIndex = terminal_row * VGA_WIDTH + terminal_column;
        // Writing the str[i] char to the video_memory
        video_memory[currentIndex] = (text_colour << 8) | str[i];

        terminal_column++;
        if (terminal_column >= VGA_WIDTH)
        {
            next_row();
        }
    }
}