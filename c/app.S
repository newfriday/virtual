.code16
.section ".s16", "ax"

movw    $1, %ax
cpuid
movw    %dx, %ax
shrw    $9, %ax
andw    $0x1, %ax
cmpw    $1, %ax
je      dispY
jmp     dispN

dispY:
    # display "Y"
    movb    $0x59, %bl
    call    dispStr
loop0:
    jmp loop0

dispN:
    # display "N"
    movb    $0x4e, %bl
    call    dispStr
loop1:
    jmp loop1

dispStr:
    movw    $0xb800, %ax
    movw    %ax, %gs
    movb    $0xf, %ah
    movb    %bl, %al
    movw    $((80*0+39)*2), %bx
    movw    %ax, %gs:(%bx)
    ret
