[bits 32]
[global _start]
extern kernel_main

_start:
    call kernel_main
    times 500 db 0x90 ;
    hlt