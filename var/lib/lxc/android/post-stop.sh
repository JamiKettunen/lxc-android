#!/bin/sh

android_rootfs="$(sed -n 's/^lxc.rootfs.path = //p' /var/lib/lxc/android/config)"
pids_to_kill="$(lsof -t $android_rootfs)"
if [ "$pids_to_kill" ]; then
    # Let's not SIGKILL because after container stop these should be Linux apps using libhybris
    kill $pids_to_kill
    # Give a bit of time for the processes to exit
    sleep 1
    # Kill the rest if they've still not gone
    kill -9 $pids_to_kill
fi

if [ -e /dev/binderfs ]; then
    umount /dev/binderfs
    rmdir /dev/binderfs
    rm /dev/*binder
fi

if [ -e /apex ]; then
    umount -R /apex
fi
if [ -e /linkerconfig ]; then
    umount /linkerconfig
fi

rm -r /dev/__properties__ /dev/socket
