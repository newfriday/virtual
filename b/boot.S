    .code16
    .section ".s16", "ax"
    .global _start
_start:
    # BS_jmpBoot  短跳转指令
    jmp label_init
    nop
    # BS_OEMName 厂商名字
    .ascii  "ForrestY"
    # BS_BytsPerSec 每扇区字节数
    .word   512
    # BPB_SecPerClus 每簇扇区数
    .byte   1
    # BPB_RsvdSecCnt 引导记录（MBR）占用的扇区数
    .word   1
    # PBP_NumFATs FAT表数目
    .byte   2
    # PBP_RootEntCnt 根目录文件最大数
    .word   0xe0
    # PBP_TotSec16 扇区总数
    .word   2880
    # PBP_Media 介质描述符
    .byte   0xf0
    # PBP_FATSz16 每FAT扇区数
    .word   9
    # PBP_SecPerTrk 每磁道扇区数
    .word   18
    # PBP_NumHeads 磁头数
    .word   2
    # PBP_HiddSec 隐藏扇区数
    .long   0
    # PBP_TotSec32 如果PBP_TotSec16为0，该域记录扇区数
    .long   0
    # BS_DrvNum 中断13的驱动器号
    .byte   0
    # BS_Reserved1 未使用
    .byte   0
    # BS_BootSig 扩展引导标记
    .byte   0x29
    # 卷序列号
    .long   0
    # 卷标
    .ascii  "VirtualBoot"
    # 文件系统类型
    .ascii  "FAT12   "

label_init:
    movw    $0x7c0, %ax
    movw	%ax, %ds
    movw	%ax, %es
    movw	%ax, %ss
    movw    $0x180, %sp
    call    DispStr

loop:
    jmp     loop

DispStr:
    movw    $BootMsg, %ax
    movw    %ax, %bp
    movw    $16, %cx
    movw    $0x1301, %ax
    movw    $0xc, %bx
    movb    $0, %dl
    int     $0x10
    ret

BootMsg:
    .ascii  "Hello, OS World!"
    .org 510
    .word 0xAA55
