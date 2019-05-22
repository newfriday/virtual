#!/bin/bash
# if open debug, use gdb to connect gdbserver
# set breakpoint at 0x90100 like "b * 0x90100"
DEBUG="false"
PWD="$(cd `dirname $0`;pwd)"

[ $# -eq 1 ] && [ "X$1" == "X-h" ] && echo "$(basename $0) debug --for debug" && exit 0
[ $# -eq 1 ] && [ "X$1" == "Xdebug" ] && DEBUG="true"

if [ "X$DEBUG" == "Xtrue" ]; then
    echo "waiting for connect gdb server..."
    qemu-system-x86_64 -machine pc-i440fx-4.0 -m 2G -smp 2,sockets=2,cores=1,threads=1  \
                       -boot strict=on -drive file=$PWD/a.img,format=raw,if=none,id=drive-fdc0-0-0 \
                       -global isa-fdc.driveA=drive-fdc0-0-0 -global isa-fdc.bootindexA=1 \
                       -qmp tcp:localhost:4444,server,nowait -S -s
else
    qemu-system-x86_64 -machine pc-i440fx-4.0 -m 2G -smp 2,sockets=2,cores=1,threads=1  \
                       -boot strict=on -drive file=$PWD/a.img,format=raw,if=none,id=drive-fdc0-0-0 \
                       -global isa-fdc.driveA=drive-fdc0-0-0 -global isa-fdc.bootindexA=1 \
                       -qmp tcp:localhost:4444,server,nowait
fi
