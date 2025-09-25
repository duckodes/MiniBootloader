[bits 32]
[global _start]
extern kernel_main

_start:
    mov byte [0xB8004], 'K'
    mov byte [0xB8005], 0x0F
    call kernel_main
    hlt