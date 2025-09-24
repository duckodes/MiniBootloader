; boot.asm
[org 0x7c00]
mov bx, 0x1000
mov ah, 0x02
mov al, 1
mov ch, 0
mov cl, 2
mov dh, 0
int 0x13

jmp 0x0000:0x1000

times 510 - ($ - $$) db 0
dw 0xAA55