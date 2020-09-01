#!/bin/bash
PD="$PWD"

DATE=$(TZ=Asia/Kolkata date +"%d%m")

ROM="$1"
##---------------------------------------------------------##

mkdir "$PD"/out/"$ROM"
cd "$PD"/work/"$ROM"/
sudo umount s p v
rm -rf s p v

# resize
e2fsck -f -y s-"$DATE".img
resize2fs -M s-"$DATE".img

e2fsck -f -y p-"$DATE".img
resize2fs -M p-"$DATE".img

##---------------------------------------------------------##

#"$PD"/.tools/img2simg s-"$DATE".img s
#rm s-"$DATE".img
"$PD"/.tools/img2sdat/img2sdat.py "$PD"/work/"$ROM"/s-"$DATE".img -o "$PD"/out/"$ROM"/ -v 4
#rm s
brotli -6jf "$PD"/out/"$ROM"/system.new.dat
#rm "$PD"/out/"$ROM"/system.new.dat

"$PD"/.tools/img2sdat/img2sdat.py "$PD"/work/"$ROM"/s-"$DATE".img -p product -o "$PD"/out/"$ROM"/ -v 4
#rm s
brotli -6jf "$PD"/out/"$ROM"/product.new.dat
#rm "$PD"/out/"$ROM"/product.new.dat

cd "$PD"/out/"$ROM"
#mv "$PD"/work/"$ROM"/*.br "$PD"/out/"$ROM"
#mv "$PD"/work/"$ROM"/*patch.dat "$PD"/out/"$ROM"
#mv "$PD"/work/"$ROM"/*transfer.list "$PD"/out/"$ROM"
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
