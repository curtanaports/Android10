#!/bin/bash
PD="$PWD"

DATE=$(TZ=Asia/Kolkata date +"%d%m")

ROM="$1"
##---------------------------------------------------------##

# resize
e2fsck -f -y "$PD"/work/"$ROM"/s-"$DATE".img
resize2fs -M "$PD"/work/"$ROM"/s-"$DATE".img

e2fsck -f -y "$PD"/work/"$ROM"/p-"$DATE".img
resize2fs -M "$PD"/work/"$ROM"/p-"$DATE".img

##---------------------------------------------------------##

"$PD"/.tools/img2simg "$PD"/work/"$ROM"/s-"$DATE".img "$PD"/work/"$ROM"/s
rm "$PD"/work/"$ROM"/s-"$DATE".img
"$PD"/.tools/img2sdat/img2sdat.py "$PD"/work/"$ROM"/s -o "$PD"/out/"$ROM"/ -v 4
rm "$PD"/work/"$ROM"/s
brotli -6jf "$PD"/out/"$ROM"/system.new.dat

"$PD"/.tools/img2simg "$PD"/work/"$ROM"/p-"$DATE".img "$PD"/work/"$ROM"/p
rm "$PD"/work/"$ROM"/p-"$DATE".img
"$PD"/.tools/img2sdat/img2sdat.py "$PD"/work/"$ROM"/p -p product -o "$PD"/out/"$ROM"/ -v 4
rm "$PD"/work/"$ROM"/p
brotli -6jf "$PD"/out/"$ROM"/product.new.dat

cd "$PD"/out/"$ROM"
mv "$PD"/.tools/common/dynamic_partitions_op_list "$PD"/out/"$ROM"
mv "$PD"/.tools/common/META-INF "$PD"/out/"$ROM"/

zip -r9 $ROM-"$DATE" * -x *.zip
mv META-INF "$PD"/.tools/common/
mv dynamic_partitions_op_list "$PD"/.tools/common/

rm *.br *.dat *.list

BUILD_END=$(date +"%s")
DIFF=$((BUILD_END - BUILD_START))

#wput "$ROM"*.zip ftp://user:pass@uploads.androidfilehost.com/
#curl -T "$ROM"*.zip ftp://user:pass@uploads.androidfilehost.com/
