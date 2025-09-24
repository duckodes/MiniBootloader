# Makefile
all:
	nasm -f bin boot.asm -o boot.bin
	gcc -ffreestanding -m32 -c kernel.c -o kernel.o
	ld -m elf_i386 -T linker.ld kernel.o -o kernel.bin
	cat boot.bin kernel.bin > os.img

run:
	qemu-system-x86_64 -drive format=raw,file=os.img