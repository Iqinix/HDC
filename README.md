As we all know huawei is releasing more and more devices with harmonyos next (openharmony / harmony os 5+) which means more possibilities for engineering or unlocked test devices.
As we also know this means no more ADB / Fastboot instead huawei now uses HDC (Huawei Device Connect) and trying to find out how to use it is not exactly easy therefore i am sharing some commands and other things.
-
-
Warnings:
-
Any set of commands that start with "hdc smode root" require the devices firmware to be userdebug which means they will NOT work with "non-debuggable" firmware.
-
-
Things to note:
-
There is no dedicated partition dump command, the best you can get is dd pulling the images into /data and using file recv to pull them onto the pc however from testing some of these images are just full of 0's.
-
-
-
-
-
reboot to mode:
hdc target boot -[mode]
-
-
pull partition:
hdc smode root
hdc file recv /dev/block/by-name/[part] [part].img
or
hdc smode root
hdc shell dd if=/dev/block/sd(d/c) of=/data/[partname].img
hdc file recv /data/[partname].img
-
-
move a file inside the phone:
hdc smode root
hdc shell dd if=/file/to/move of=place/to/move.extension
-
-
add / remove buildprop hides:
hdc smode root
hdc shell
mount | grep sys_prod
mount -o remount,rw /sys_prod
dd if=/sys_prod/etc/param/hw_defaults.para of=/data/hw_defaults.para
exit
hdc fille recv /data/hw_defaults.para
[[edit "hw_defaults.para" and change "const.product.hide = true" to false]]
hdc file send /path/to/editted.para /sts_prod/etc/param
-
-
Find what sdd / sdc corresponds to what partition:
hdc smode root
hdc shell ls -l /dev/block/by-name
-
-
mount partition r/w:
hdc smode root
hdc shell
mount | grep *partname*
mount -o remount,rw /*partname*
