#!/bin/bash
PD="$PWD"

DATE=$(TZ=Asia/Kolkata date +"%d%m")

token= # telegram bot token
chatid= # telegram chat id

ROM="$1"
##---------------------------------------------------------##

function exports {
	export BOT_MSG_URL="https://api.telegram.org/bot$token/sendMessage"
	export BOT_BUILD_URL="https://api.telegram.org/bot$token/sendDocument"
	export BOT_STICKER_URL="https://api.telegram.org/bot$token/sendSticker"
}
exports

##---------------------------------------------------------##

function tg_post_msg {
	curl -s -X POST "$BOT_MSG_URL" -d chat_id="$2" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"
}

##---------------------------------------------------------##

function tg_post_sticker {
if [ "$STICKER" = 1 ]
then
	curl -v -F chat_id="$2" "$BOT_STICKER_URL" \
	-F "disable_notification=true" \
	-F sticker=@/$TELEGRAM_DIR/stickers/$1.tgs
fi
}

##---------------------------------------------------------##

function tg_post_build {
	#Post MD5Checksum alongwith for easeness
	MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)

	#Show the Checksum alongwith caption
	curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
	-F chat_id="$2"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$3

<b>MD5 Checksum : </b><code>$MD5CHECK</code>"  
}

##---------------------------------------------------------##

function tg_fpush {
	#Post MD5Checksum alongwith for easeness
	#MD5CHECK=$(md5sum "$2" | cut -d' ' -f1)

	#Show the Checksum alongwith caption
	bash t -H -D -t $token -c $1 -f $2
	#"$3"$'\n'$'\n'"<b>MD5 Checksum : </b><code>$MD5CHECK</code>"
}

cd "$PD"/work/"$ROM"/
sudo umount s p v
rm -rf s p v

tg_post_msg "<b>Port status 1 - </b>Success!"$'\n'"<code>Reducing size of all images before packing...</code>" "$chatid"

# resize
e2fsck -f -y s-"$DATE".img
resize2fs -M s-"$DATE".img

e2fsck -f -y p-"$DATE".img
resize2fs -M p-"$DATE".img

##---------------------------------------------------------##

tg_post_msg "<b>Converting and compressing images...</b>" "$chatid"

"$PD"/.tools/img2simg s-"$DATE".img s
rm s-"$DATE".img
"$PD"/.tools/ss s
rm s
brotli -6kf system.new.dat
rm system.new.dat

cd "$PD"/work/"$ROM"
"$PD"/.tools/img2simg p-"$DATE".img p
rm p-"$DATE".img
"$PD"/.tools/pp p
rm p
brotli -6kf product.new.dat
rm product.new.dat

tg_post_msg "<b>Done</b>"$'\n'"<code>Making Recovery package...</code>" "$chatid"
mkdir "$PD"/out/"$ROM"
cd "$PD"/out/"$ROM"
mv "$PD"/work/"$ROM"/*.br "$PD"/out/"$ROM"
mv "$PD"/work/"$ROM"/*patch.dat "$PD"/out/"$ROM"
mv "$PD"/work/"$ROM"/*transfer.list "$PD"/out/"$ROM"
mv "$PD"/.tools/common/dynamic_partitions_op_list "$PD"/out/"$ROM"
mv "$PD"/.tools/common/META-INF "$PD"/out/"$ROM"/

zip -r9 $ROM-"$DATE" * -x *.zip
mv META-INF "$PD"/.tools/common/
mv dynamic_partitions_op_list "$PD"/.tools/common/

rm *.br *.dat *.list

BUILD_END=$(date +"%s")
DIFF=$((BUILD_END - BUILD_START))

tg_post_msg "<b>Port status 2 - </b>Success!"$'\n'"<code>Took $((DIFF / 60)) minutes and $((DIFF % 60)) seconds" "$chatid"

#wput "$ROM"*.zip ftp://user:pass@uploads.androidfilehost.com/
#curl -T "$ROM"*.zip ftp://user:pass@uploads.androidfilehost.com/

function zip_push {
	if [ "$PTTG" = 1 ]
	then
#		tg_post_sticker "done" "$chatid"
		tg_post_build "$PD"/out/"$ROM"/*.zip "$chatid" "Beta"
	fi
}

tg_post_msg "<b>Upload - </b>Done!"$'\n'"<code>Don't forget to flash </code>#vendor" "$chatid"
