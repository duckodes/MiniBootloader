CC = x86_64-elf-gcc
AS = nasm
LD = x86_64-elf-ld
OBJCOPY = x86_64-elf-objcopy

all:
	$(AS) -f bin boot.asm -o boot.bin
	$(AS) -f elf32 kernel.asm -o kernel.o
	$(CC) -m32 -ffreestanding -c kernelC.c -o kernelC.o
	$(LD) -m elf_i386 -nostdlib -Ttext=0x100000 -e _start kernel.o kernelC.o -o kernel.elf
	$(OBJCOPY) -O binary kernel.elf kernel.bin
	dd if=/dev/zero of=os.img bs=512 count=100
	dd if=boot.bin of=os.img conv=notrunc
	dd if=kernel.bin of=os.img bs=512 seek=1 conv=notrunc

clean:
	rm -f *.o *.bin *.elf *.img

run:
	qemu-system-i386 -drive format=raw,file=os.img