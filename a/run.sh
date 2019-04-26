#!/bin/bash
DEBUG="false"

[ $# -eq 1 ] && [ "X$1" == "X-h" ] && echo "$(basename $0) debug --for debug" && exit 0
[ $# -eq 1 ] && [ "X$1" == "Xdebug" ] && DEBUG="true"

if [ "X$DEBUG" == "Xtrue" ]; then
    echo "waiting for connect gdb server..."
    qemu-system-x86_64 -boot order=a -fda "$(pwd)"/a.img -s -S >/dev/null 2>&1
else
    qemu-system-x86_64 -boot order=a -fda "$(pwd)"/a.img
fi
