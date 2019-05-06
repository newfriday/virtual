    .code16
    .section ".s16", "ax"
    .include "boot.inc"
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
    # BPB_NumFATs FAT表数目
    .byte   2
    # BPB_RootEntCnt 根目录文件最大数
    .word   0xe0
    # BPB_TotSec16 扇区总数
    .word   2880
    # BPB_Media 介质描述符
    .byte   0xf0
    # BPB_FATSz16 每FAT扇区数
    .word   9
    # BPB_SecPerTrk 每磁道扇区数
BPB_SecPerTrk:
    .word   18
    # BPB_NumHeads 磁头数
    .word   2
    # BPB_HiddSec 隐藏扇区数
    .long   0
    # BPB_TotSec32 如果PBP_TotSec16为0，该域记录扇区数
    .long   0
    # BS_DrvNum 中断13的驱动器号
BS_DrvNum:
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

    # reset floppy: AH=0,DL=drive number
    xorb    %ah, %ah
    xorb    %dl, %dl
    int     $0x13
    # 下面在 A 盘的根目录寻找 APP.BIN
    # 根目录起始扇区号 SectorNoOfRootDirectory
    movw    $SectorNoOfRootDirectory, wSectorNo
label_search_in_root_dir_begin:
    # 判断根目录区是不是已经读完
    movw    wRootDirSizeForLoop, %ax
    cmp     0, %ax
    # 如果读完表示没有找到 LOADER.BIN
    jz      label_no_loaderbin

    # 开始一次文件名匹配, 依次查找14个扇区
    movw    wRootDirSizeForLoop, %cx
    dec     %cx
    movw    %cx, wRootDirSizeForLoop

    movw    $BaseOfLoader, %ax
    # es <- BaseOfLoader
    movw    %ax, %es

    # bx <- OffsetOfLoader
    movw    $OffsetOfLoader, %bx

    # ax <- Root Directory 中的某 Sector 号
    movw    wSectorNo, %ax
    movb    $1, %cl
    call    ReadSector

    # ds:si -> "APP     BIN"
    movw    $LoaderFileName, %si
    # es:di -> BaseOfLoader:0100
    movw    $OffsetOfLoader, %di
    cld
    movw    $0x10, %dx

label_search_for_loaderbin:
    # 循环次数控制
    cmp     $0, %dx
    # 如果已经读完了一个 Sector,就跳到下一个 Sector
    jz      label_goto_next_sector_in_root_dir
    dec     %dx
    movw    $11, %cx

label_cmp_filename:
    cmp     $0, %cx
    # 如果比较了 11 个字符都相等, 表示找到
    jz      label_filename_found
    dec     %cx

    # ds:si -> al
    lodsb
    # es:di
    cmpb    %al, %es:(%di)

    jz      label_go_on

    # 只要发现不一样的字符就表明本 DirectoryEntry
    # 不是我们要找的 APP.BIN
    jmp     label_different

label_go_on:
    inc     %di
    # 继续循环
    jmp     label_cmp_filename

label_different:
    # else `. di &= E0 为了让它指向本条目开头
    #       | di += 20h  下一个目录条目
    andw    $0xffe0, %di
    addw    $0x20, %di
    movw    $LoaderFileName, %si
    jmp     label_search_for_loaderbin

label_goto_next_sector_in_root_dir:
    addw    $1, wSectorNo
    jmp     label_search_in_root_dir_begin

label_no_loaderbin:
    # "No LOADER."
    movb    $2, %dh
    # 显示字符串
    call    DispStr
loop0:
    jmp     loop0

# 找到 LOADER.BIN 后便来到这里继续
label_filename_found:
    # "Ready.   "
    movb    $1, %dh
    call    DispStr
loop1:
    jmp     loop1

#----------------------------------------------------------------------------
# 函数名: ReadSector
#----------------------------------------------------------------------------
# 作用:
#   从第 ax 个 Sector 开始, 将 cl 个 Sector 读入 es:bx 中
ReadSector:
    # -----------------------------------------------------------------------
    # 怎样由扇区号求扇区在磁盘中的位置 (扇区号 -> 柱面号, 起始扇区, 磁头号)
    # -----------------------------------------------------------------------
    # 设扇区号为 x
    #                          ┌ 柱面号 = y >> 1
    #       x           ┌ 商 y ┤
    # -------------- => ┤      └ 磁头号 = y & 1
    #  每磁道扇区数     │
    #                   └ 余 z => 起始扇区号 = z + 1
    pushl   %ebp
    movl    %esp, %ebp

    # 辟出两个字节的堆栈区域保存要读的扇区数: byte [bp-2]
    subl    $2, %esp
    movb    %cl, -2(%ebp)

    # 保存 bx
    pushw   %bx

    # bl: 除数
    movb    BPB_SecPerTrk, %bl

    # y 在 al 中, z 在 ah 中
    div     %bl
    # z++
    inc     %ah

    # cl <- 起始扇区号
    movb    %ah, %cl

    # dh <- y
    movb    %al, %dh
    # y >> 1 (y/BPB_NumHeads)
    shr     $1, %al
    # ch <- 柱面号
    movb    %al, %ch
    # dh & 1 = 磁头号
    and     $1, %dh
    # 恢复 bx
    popw    %bx
    # 至此, "柱面号, 起始扇区, 磁头号" 全部得到
    # 驱动器号 (0 表示 A 盘)
    movb    BS_DrvNum,  %dl

bios_read_sector:
    # 读
    movb    $2, %ah
    # 读 al 个扇区
    movb    -2(%ebp), %al
    int     $0x13
    jc      disp_error
    add     $2, %esp
    popl    %ebp
    ret
disp_error:
    movb    $3, %dh
    call    DispStr
loop2:
    jmp     loop2

#----------------------------------------------------------------------------
# 函数名: DispStr
#----------------------------------------------------------------------------
# 作用:
#   显示一个字符串, 函数开始时 dh 中应该是字符串序号(0-based)
DispStr:
    movw    $MessageLength, %ax
    mul     %dh
    add     $BootMessage, %ax
    movw    %ax, %bp
    movw    %ds, %ax
    movw    %ax, %es
    movw    $MessageLength, %cx
    movw    $0x1301, %ax
    movw    $0xc, %bx
    movb    $0, %dl
    int     $0x10
    ret

# -----------------------------------------------------------
# 变量
# Root Directory 占用的扇区数，
# 在循环中会递减至零
wRootDirSizeForLoop:
    .word   RootDirSectors
# 要读取的扇区号
wSectorNo:
    .word   0
# 奇数还是偶数
bOdd:
    .byte   0
# -----------------------------------------------------------

# 字符串常量
# APP.BIN 之文件名
LoaderFileName:
    .ascii  "APP     BIN"
    .byte   0
# 为简化代码, 下面每个字符串的长度均为 MessageLength
    .set    MessageLength, 9
# 9字节, 不够则用空格补齐. 序号 0
BootMessage:
    .ascii  "Booting  "
# 9字节, 不够则用空格补齐. 序号 1
Message1:
    .ascii  "Ready.   "
# 9字节, 不够则用空格补齐. 序号 2
Message2:
    .ascii  "No LOADER"
# 9字节, 不够则用空格补齐. 序号 3
Message3:
    .ascii  "Error    "
BootMsg:
BootMsg:
    .ascii  "Hello, OS World!"
    .org 510
    .word 0xAA55
