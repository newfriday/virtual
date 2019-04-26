OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64", "elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
ENTRY(_start)

SECTIONS
{
    . = 0;
    .boot : {*(.s16)}
    . = ASSERT(. <= 512, "Boot too big!");
    /**
    . = 0x10;
    .boot : {*(.s16)}
    */
}
