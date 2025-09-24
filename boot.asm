[bits 16]
[org 0x7C00]
[global _start]

_start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; 設定 GDT
    lgdt [gdt_descriptor]

    ; 開啟保護模式
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; 跳到保護模式
    jmp 0x08:protected_mode

gdt_start:
    dq 0x0000000000000000         ; null
    dq 0x00CF9A000000FFFF         ; code
    dq 0x00CF92000000FFFF         ; data
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start
gdt_end:

[bits 32]
protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov esp, 0x90000

    ; 顯示 B（bootloader 執行成功）
    mov byte [0xB8000], 'B'
    mov byte [0xB8001], 0x0F

    ; 切回 real mode 讀磁碟
    mov eax, cr0
    and eax, 0xFFFFFFFE
    mov cr0, eax
    jmp 0x0000:real_mode

[bits 16]
real_mode:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; 讀 kernel 到 0x0000:0x1000
    mov ax, 0x0000
    mov es, ax
    mov bx, 0x1000

    ; 可先重置磁碟，提高成功率
    mov ah, 0x00
    mov dl, 0x80
    int 0x13

    ; 讀 8 sectors 從 LBA 對應 CHS (C=0,H=0,S=2)
    mov ah, 0x02
    mov al, 8
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x80
    int 0x13
    jc disk_error

    ; 啟用 A20（先試 BIOS 快速方法）
enable_a20_fast:
    in  al, 0x92
    test al, 0x02
    jnz  a20_ok             ; 已啟用
    or  al, 0x02
    out 0x92, al

    ; 簡單確認一次
    in  al, 0x92
    test al, 0x02
    jnz  a20_ok
    jmp enable_a20_bios

enable_a20_bios:
    mov ax, 0x2401
    int 0x15
    jc  enable_a20_kbc
    cmp ah, 0x00
    jne enable_a20_kbc
    jmp a20_ok

enable_a20_kbc:
    ; 8042 法加 timeout，避免卡死
    mov cx, 0xFFFF
.wait_in_empty:
    in  al, 0x64
    test al, 0x02
    jz   .do_disable
    loop .wait_in_empty
    jmp a20_ok              ; 超時就跳過

.do_disable:
    mov al, 0xAD
    out 0x64, al

    mov cx, 0xFFFF
.wait_in_empty2:
    in  al, 0x64
    test al, 0x02
    jnz  .wait_in_empty2
    mov al, 0xD0
    out 0x64, al

    mov cx, 0xFFFF
.wait_out_full:
    in  al, 0x64
    test al, 0x01
    jz   .wait_out_full
    in  al, 0x60
    or  al, 0x02            ; 設 A20
    mov ah, al

    mov cx, 0xFFFF
.wait_in_empty3:
    in  al, 0x64
    test al, 0x02
    jnz  .wait_in_empty3
    mov al, 0xD1
    out 0x64, al

    mov cx, 0xFFFF
.wait_in_empty4:
    in  al, 0x64
    test al, 0x02
    jnz  .wait_in_empty4
    mov al, ah
    out 0x60, al

    mov cx, 0xFFFF
.wait_in_empty5:
    in  al, 0x64
    test al, 0x02
    jnz  .wait_in_empty5
    mov al, 0xAE
    out 0x64, al

a20_ok:
    ; 回到保護模式
    lgdt [gdt_descriptor]
    mov eax, cr0
    or  eax, 1
    mov cr0, eax
    jmp 0x08:back_to_pm

; --- 8042 helpers ---
wait_input_empty:
    in  al, 0x64
    test al, 0x02
    jnz  wait_input_empty
    ret

wait_output_full:
    in  al, 0x64
    test al, 0x01
    jz   wait_output_full
    ret

[bits 32]
back_to_pm:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov esp, 0x90000

    ; 顯示 L（載入成功）
    mov byte [0xB8002], 'L'
    mov byte [0xB8003], 0x0F

    ; 搬運 4096 bytes 到 0x100000
    mov esi, 0x1000
    mov edi, 0x100000
    mov ecx, 4096
    rep movsb

    ; 跳到 kernel
    jmp 0x08:0x100000

disk_error:
    mov byte [0xB8004], 'E'
    mov byte [0xB8005], 0x4C
    hlt

times 510 - ($ - $$) db 0
dw 0xAA55