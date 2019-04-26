    .code16
    .section ".s16", "ax"
    .global _start
_start:

    # Normalize the start address
    ljmp    $0x07c0, $DispStr

DispStr:
    movw    %cs, %ax
    movw    %ax, %ds
    movw    %ax, %es
    movw    %ax, %ss
    movw    $0x100, %sp

    movw    $boot_msg, %ax
    movw    %ax, %bp
    movw    $16, %cx
    movw    $0x1301, %ax
    movw    $0xc, %bx
    movb    $0, %dl

    int     $0x10
loop:
    jmp     loop

boot_msg:
    .ascii  "Hello, OS World!"
    .org 510
    .word 0xAA55
