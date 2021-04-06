FILES = build/kernel.asm.o build/kernel.o build/cio.o
INCLUDES = -Isrc/
FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

build: build/bin/bootloader.bin build/bin/kernel.bin
	rm -rf /build/bin/turtleos.bin
	dd if=build/bin/bootloader.bin >> build/bin/turtleos.bin
	dd if=build/bin/kernel.bin >> build/bin/turtleos.bin
	dd if=/dev/zero bs=512 count=100 >> build/bin/turtleos.bin

build/bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o build/kernelfull.o
	i686-elf-gcc $(FLAGS) -T src/linker.ld -o build/bin/kernel.bin -ffreestanding -O0 -nostdlib build/kernelfull.o
build/bin/bootloader.bin: src/bootloader/bootloader.asm
	nasm -f bin src/bootloader/bootloader.asm -o build/bin/bootloader.bin
build/kernel.asm.o: src/kernel.asm
	nasm -f elf -g src/kernel.asm -o build/kernel.asm.o
build/kernel.o: src/kernel.c
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c src/kernel.c -o build/kernel.o
build/cio.o:
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c src/cio.c -o build/cio.o

make_image:
	dd if=build/bin/turtleos.bin of=build/turtleos.img bs=51200 count=1 conv=notrunc

clean:
	rm -f build/bin/*
	rm -f build/kernelfull.o
	rm -f build/turtleos.img
	rm -f ${FILES}
run_image:
	qemu-system-x86_64 -hda build/turtleos.img
run_binary:
	qemu-system-x86_64 -hda build/bin/turtleos.bin

clean_run: clean build
	qemu-system-x86_64 -hda build/bin/turtleos.bin

prepare_project: create_build_directories install_dependencies
	echo "Dependencies installed & Project folders created!"
create_build_directories:
	mkdir build
	mkdir build/bin
install_dependencies:
	sudo apt install build-essential -y
	sudo apt install bison -y
	sudo apt install flex -y
	sudo apt install libgmp3-dev -y
	sudo apt install libmpc-dev -y
	sudo apt install libmpfr-dev -y
	sudo apt install texinfo -y
	sudo apt install libisl-dev -y