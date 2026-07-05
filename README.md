As we all know huawei is releasing more and more devices with harmonyos next (openharmony / harmony os 5+) which means more possibilities for engineering or unlocked test devices. </p>
As we also know this means no more ADB / Fastboot instead huawei now uses HDC (Huawei Device Connect) and trying to find out how to use it is not exactly easy therefore i am sharing some commands and other things.
##
Warnings: </p>
Any set of commands that start with "hdc smode root" require the devices firmware to be userdebug which means they will NOT work with "non-debuggable" firmware. </p>
The "Dump all parts.bat" file only dumps the parts that show as a result of "ls -l /dev/block/by-name" therefore some partitions such as xloader and probably some others wont be dumped. </p>
If your planning on doing a command that involves pulling, editting and pushing a system file i would reccommend making a backup of the original. </p>
##
##
Things to note: </p>
There is no dedicated partition dump command, the best you can get is dd pulling the images into /data and using file recv to pull them onto the pc however from testing some of these images are just full of 0's. </p>
To use the ".bat" files place them in the folder with "HDC.exe" and run.
##
##
##
##
##
reboot to mode: </p>
hdc target boot -[mode]
##
##
pull partition: </p>
hdc smode root </p>
hdc file recv /dev/block/by-name/[part] [part].img </p>
or </p>
hdc smode root </p>
hdc shell dd if=/dev/block/sd(d/c) of=/data/[partname].img </p>
hdc file recv /data/[partname].img </p>
##
##
move a file inside the phone: </p>
hdc smode root </p>
hdc shell dd if=/file/to/move of=place/to/move.extension </p>
##
##
add / remove buildprop hides: </p>
hdc smode root </p>
hdc shell </p>
mount | grep sys_prod </p>
mount -o remount,rw /sys_prod </p>
dd if=/sys_prod/etc/param/hw_defaults.para of=/data/hw_defaults.para </p>
exit </p>
hdc fille recv /data/hw_defaults.para </p>
[[edit "hw_defaults.para" and change "const.product.hide = true" to false]] </p>
hdc file send /path/to/editted.para /sts_prod/etc/param </p>
##
##
Find what sdd / sdc corresponds to what partition: </p>
hdc smode root </p>
hdc shell ls -l /dev/block/by-name </p>
##
##
mount partition r/w: </p>
hdc smode root </p>
hdc shell </p>
mount | grep [partname] </p>
mount -o remount,rw /[partname] </p>
