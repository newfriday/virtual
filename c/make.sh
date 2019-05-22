#!/bin/bash
as --64 -gstabs -o app.o app.S
ld -o app app.o -Tapp.ld

off="$(objdump -h app |grep .s16 |awk '{print $6}')"
offDec="$(printf %d 0x$off)"

size="$(objdump -h app |grep .s16 |awk '{print $3}')"
sizeDec="$(printf %d 0x$size)"

rm -f app.o app

make OFF=$offDec SIZE=$sizeDec
