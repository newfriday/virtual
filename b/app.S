.code16
.section ".s16", "ax"

movw    $0xb800, %ax
movw    %ax, %gs
movb    $0xf, %ah
movb    $0x4c, %al
movw    $((80*0+39)*2), %bx
movw    %ax, %gs:(%bx)
loop:
        jmp loop
