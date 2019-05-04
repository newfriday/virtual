SRC=boot.S
BIN=$(subst .S,.bin,$(SRC))
OBJ=$(subst .S,.o,$(SRC))
TEXT=$(subst .S,.text,$(SRC))
DIS=$(subst .S,.dis,$(SRC))
LDScript=$(subst .S,.ld,$(SRC))

.PHONY : everything

everything: $(BIN)
	dd if=/dev/zero of=a.img bs=512 count=2880
	losetup /dev/loop0 a.img
	mkdosfs -F 12 /dev/loop0
	losetup -d /dev/loop0
	dd if=$(BIN) ibs=512 skip=4096 of=a.img obs=512 seek=0 count=1 conv=notrunc

$(BIN): $(OBJ) $(LDScript)
	ld -o $(BIN) $(OBJ) -T$(LDScript)

$(OBJ): $(SRC)
	as --64 -gstabs -o $(OBJ) $(SRC)
	#dd if=$(OBJ) bs=64 skip=1 of=$(TEXT) seek=0 count=8
	#ndisasm -o 0x7c00 $(TEXT) > $(DIS)

clean:
	rm -f $(BIN) $(OBJ) $(DIS) $(TEXT) a.img

