#include "kernel.h"
#include "cio.h"

void kernel_main()
{
    initialize_video_memory();
    clean_terminal();

    print_str("I am alive!\n");
    print_str("Test 123\n");
    set_text_color(3);
    print_str("Turtle OS");
}