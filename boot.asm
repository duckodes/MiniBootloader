[bits 16]
[org 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ax, 0x0003
    int 0x10

    mov dh, 10
    mov dl, 30
    mov bh, 0
    mov ah, 2
    int 0x10

    mov si, welcome
.print_welcome:
    lodsb
    cmp al, 0
    je .progress
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0F
    int 0x10
    jmp .print_welcome

.progress:
    mov cx, 30
    xor bx, bx
.progress_loop:
    mov dh, 12
    mov dl, bl
    add dl, 30

    cmp dl, 48
    jae .skip_update_cursor

    mov bh, 0
    mov ah, 2
    int 0x10

.skip_update_cursor:
    push bx
    mov ah, 0x09
    mov al, 219
    mov bl, 0x0A
    mov cx, 1
    int 0x10
    pop bx

    call delay
    inc bx
    cmp bx, 30
    jl .progress_loop

    call delay

    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h
    mov si, desktop
    mov ah, 0
    int 16h
.halt:
    mov ah, 0
    int 16h
    hlt
.print_desktop:
    lodsb
    cmp al, 0
    je .halt
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0F
    int 0x10
    jmp .print_desktop
delay:
    mov cx, 0xFFFF
    .outer:
        push cx
        mov cx, 0xFFF
    .inner:
        nop
        loop .inner
        pop cx
        loop .outer
        ret
.wait:
    nop
    loop .wait
    ret

welcome db 'WELCOME DUCKODE OS', 0
desktop db 'Hello Desktop!', 0

times 510 - ($ - $$) db 0
dw 0xAA55