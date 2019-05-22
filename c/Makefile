SRC=boot.S
BIN=$(subst .S,.bin,$(SRC))
OBJ=$(subst .S,.o,$(SRC))
TEXT=$(subst .S,.text,$(SRC))
DIS=$(subst .S,.dis,$(SRC))
LDScript=$(subst .S,.ld,$(SRC))

APPSRC=app.S
APPOBJ=$(subst .S,.o,$(APPSRC))
APPBIN=$(subst .S,.bin,$(APPSRC))
APPLD=$(subst .S,.ld,$(APPSRC))
APPDBG=$(subst .S,,$(APPSRC))

.PHONY : everything

everything: $(BIN) $(APPBIN)
	dd if=/dev/zero of=a.img bs=512 count=2880
	losetup /dev/loop0 a.img
	mkdosfs -F 12 /dev/loop0
	losetup -d /dev/loop0
	dd if=$(BIN) ibs=512 skip=4096 of=a.img obs=512 seek=0 count=1 conv=notrunc
	losetup /dev/loop0 a.img
	mount -t msdos -o "fat=12" /dev/loop0 /mnt/floppy/
	cp $(APPBIN) /mnt/floppy/
	umount /mnt/floppy
	losetup -d /dev/loop0

$(OBJ): $(SRC)
	as --64 -gstabs -o $(OBJ) $(SRC)

$(BIN): $(OBJ) $(LDScript)
	ld -o $(BIN) $(OBJ) -T$(LDScript)

$(APPBIN): $(APPSRC)
	as --64 -gstabs -o $(APPOBJ) $(APPSRC)
	ld -o $(APPDBG) $(APPOBJ) -T$(APPLD)
	dd if=$(APPDBG) ibs=1 skip=$(OFF) of=$(APPBIN) seek=0 count=$(SIZE)
	#nasm -o $(APPBIN) $(APPSRC)

clean:
	rm -f $(BIN) $(APPBIN) $(OBJ) $(APPOBJ) $(DIS) $(TEXT) $(APPDBG) a.img
