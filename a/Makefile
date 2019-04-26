mbr:	mbr.o	mbr.ld
	ld -o mbr mbr.o -Tmbr.ld
	dd if=mbr ibs=512 skip=4096 of=a.img obs=512 seek=0 count=1
mbr.o:	mbr.S
	as --64 -gstabs -o mbr.o mbr.S
	dd if=mbr.o ibs=1 skip=269 of=mbr.s16 seek=0 count=512
clean:
	rm -f mbr.s16 mbr.o	mbr
