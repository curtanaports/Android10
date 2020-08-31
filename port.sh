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


tg_post_msg "<b>Started a Port build - $ROM</b>"$'\n'"<code>Extarcting Rom zip...</code>" "$chatid"
BUILD_START=$(date +"%s")

sudo mkdir "$PD"/out
sudo mkdir "$PD"/out/"$ROM"
sudo mkdir "$PD"/in
sudo mkdir "$PD"/in/"$ROM"
sudo mkdir "$PD"/work
sudo mkdir "$PD"/work/"$ROM"
mv *.zip "$PD"/in/"$ROM"/

unzip -n -q -d "$PD"/out/"$ROM" "$PD"/in/"$ROM"/*.zip -x firmware-update/abl.elf firmware-update/BTFM.bin firmware-update/cmnlib64.mbn firmware-update/cmnlib.mbn firmware-update/devcfg.mbn firmware-update/dspso.bin firmware-update/hyp.mbn firmware-update/keymaster.mbn firmware-update/mdtp.img firmware-update/mdtpsecapp.mbn firmware-update/NON-HLOS.bin firmware-update/pmic.elf firmware-update/rpm.mbn firmware-update/splash.img firmware-update/tz.mbn firmware-update/xbl.elf boot.img dtbo.img vendor.* cust.*
rm -rf "$PD"/out/$ROM/firmware-update

tg_post_msg "<b>Done</b>"$'\n'"<code>Making Images from Port rom...</code>" "$chatid"

brotli -j -v -d "$PD"/out/$ROM/system.new.dat.br "$PD"/out/$ROM/system.new.dat
.tools/d2is "$PD"/out/$ROM/system.transfer.list "$PD"/out/$ROM/system.new.dat "$PD"/work/"$ROM"/s-"$DATE".img

rm -rf "$PD"/out/$ROM/*

##---------------------------------------------------------##

rm -rf "$PD"/work/"$ROM"/s && mkdir "$PD"/work/"$ROM"/s
sudo mount -o loop "$PD"/work/"$ROM"/s-"$DATE".img "$PD"/work/"$ROM"/s

sudo rm "$PD"/work/"$ROM"/s/system/etc/device_features/*xml

tg_post_msg "<b>Done</b>"$'\n'"<code>Adapting to Dynamic layout...</code>" "$chatid"
# product
cp "$PD"/.tools/p.img "$PD"/work/"$ROM"/p-"$DATE".img
rm -rf "$PD"/work/"$ROM"/p && mkdir "$PD"/work/"$ROM"/p

# increase product image size
dd if=/dev/zero bs=1M count=1000 >> "$PD"/work/"$ROM"/p-"$DATE".img
e2fsck -f -y "$PD"/work/"$ROM"/p-"$DATE".img
resize2fs "$PD"/work/"$ROM"/p-"$DATE".img

tg_post_msg "<b>Making changes for Curtana...</b>"  "$chatid"

# start masking changes
sudo mount -o loop "$PD"/work/"$ROM"/p-"$DATE".img "$PD"/work/"$ROM"/p
sudo rm -rf "$PD"/work/"$ROM"/p/*
sudo cp -a -v "$PD"/work/"$ROM"/s/system/product/. "$PD"/work/"$ROM"/p/

sudo rm -rf "$PD"/work/"$ROM"/s/system/product
sudo rm -rf "$PD"/work/"$ROM"/s/product

sudo cp -r -v "$PD"/.tools/work/g/root/. "$PD"/work/"$ROM"/s/

sudo cp -a -v "$PD"/work/"$ROM"/s/vendor "$PD"/work/"$ROM"/s/product


cd "$PD"/work/"$ROM"/s/
sudo chmod 0750 init.rc
sudo chmod 0750 init.recovery.hardware.rc
sudo chmod 0750 init.recovery.qcom.rc
sudo chown root:2000 init.rc
sudo chown root:2000 init.recovery.hardware.rc
sudo chown root:2000 init.recovery.qcom.rc
sudo chmod 0755 system

cd system
sudo rm -rf data-app

cd bin
sudo chmod 0755 audio_set_params btcit elliptic_recording_tool ext_logger fatal_error fsck.ntfs ghr mem_parser mifunctiontest mishow.sh mkfs.ntfs mount.ntfs odm_vib_cal procmem qmesa_parser qmesa.sh qvrdatalogger qvrservice qvrservicetest qvrservicetest64 rtspclient rtspserver strace tcpdump tcpdump_v2 tinyhostless vibrator_test hwservicemanager

sudo chown root:2000 audio_set_params btcit elliptic_recording_tool ext_logger fatal_error fsck.ntfs ghr mem_parser mifunctiontest mishow.sh mkfs.ntfs mount.ntfs odm_vib_cal procmem qmesa_parser qmesa.sh qvrdatalogger qvrservice qvrservicetest qvrservicetest64 rtspclient rtspserver strace tcpdump tcpdump_v2 tinyhostless vibrator_test hwservicemanager

cd ..
sudo chmod 0751 bin
sudo chown root:2000 bin

cd etc
sudo chmod 0644 hosts
sudo chmod -R 0644 display
sudo chmod 0755 display

sudo chmod -R 0644 init
sudo chmod 0755 init

sudo chmod -R 0644 device_features
sudo chmod 0755 device_features

sudo chmod -R 0644 qvr
sudo chmod 0755 qvr

sudo chmod -R 0644 sensors
sudo chmod 0755 sensors/proto
sudo chmod 0755 sensors

sudo chmod -R 0644 vintf
sudo chmod 0755 vintf/manifest
sudo chmod 0755 vintf

cd ..
sudo chmod 0755 etc

cd lib
sudo chmod -R 0644 rfsa
sudo chmod 0755 rfsa/adsp
sudo chmod 0755 rfsa

sudo chmod 0644 android.hardware.nfc@1.0.so android.hardware.nfc@1.1.so android.hardware.nfc@1.2.so libblurbuster.so libchromaflash.so libcodec2_soft_av1dec.so libdualcameraddm.so libfiltergenerator.so libhazebuster.so libjni_blurbuster.so libjni_chromaflash.so libjni_dualcamera.so libjni_filtergenerator.so libjni_hazebuster.so libjni_load_serinum.so libjni_optizoom.so libjni_seestraight.so libjni_sharpshooter.so libjni_stillmore.so libjni_trueportrait.so libjni_truescanner_v2.so libjni_ubifocus.so libmetricslogger.so libmiuiimageutilities.so libnqnfc_nci_jni.so libnqnfc-nci.so liboptizoom.so libseemore.so libseestraight.so libsensor_calibration.so libsn100nfc_nci_jni.so libsn100nfc-nci.so libstagefright_bufferpool@2.0.so libstatssocket.so libsubtitle_jni.so libtrueportrait.so libtruescanner.so libubifocus.so vendor.qti.hardware.audiohalext-utils.so vendor.qti.hardware.sigma_miracast@1.0-halimpl.so vendor.xiaomi.hardware.vibratorfeature@1.0.so libclang_rt.ubsan_standalone-arm-android.so libcodec2_hidl@1.0.so libcodec2_soft_aacdec.so libcodec2_soft_aacenc.so libcodec2_soft_amrnbdec.so libcodec2_soft_amrnbenc.so libcodec2_soft_amrwbdec.so libcodec2_soft_amrwbenc.so libcodec2_soft_avcdec.so libcodec2_soft_avcenc.so libcodec2_soft_common.so libcodec2_soft_flacdec.so libcodec2_soft_flacenc.so libcodec2_soft_g711alawdec.so libcodec2_soft_g711mlawdec.so libcodec2_soft_gsmdec.so libcodec2_soft_h263dec.so libcodec2_soft_h263enc.so libcodec2_soft_hevcdec.so libcodec2_soft_hevcenc.so libcodec2_soft_mp3dec.so libcodec2_soft_mpeg2dec.so libcodec2_soft_mpeg4dec.so libcodec2_soft_mpeg4enc.so libcodec2_soft_opusdec.so libcodec2_soft_opusenc.so libcodec2_soft_rawdec.so libcodec2_soft_vorbisdec.so libcodec2_soft_vp8dec.so libcodec2_soft_vp8enc.so libcodec2_soft_vp9dec.so libcodec2_soft_vp9enc.so libcom.xiaomi.camera.algojni.so libcom.xiaomi.camera.mianodejni.so libDiagService.so libdolphin.so libdrm.so libeye_tracking_dsp_sample_stub.so libframeextension.so libmedia_codecserviceregistrant.so libopus.so libprotobuf-cpp-full-rtti.so libqdMetaData.so libQSEEComAPI_system.so libqvr_cam_cdsp_driver_stub.so libqvrcamera_client.qti.so libqvr_cdsp_driver_stub.so libqvr_eyetracking_plugin.so libqvrservice_client.qti.so libqvrservice_ov7251_hvx_tuning.so libqvrservice_ov9282_hvx_tuning.so libqvrservice.so libsensorslog.so libskewknob_system.so libsns_device_mode_stub.so libsnsdiaglog.so libsns_fastRPC_util.so libsns_low_lat_stream_stub.so libssc.so libvpx.so libvr_amb_engine.so libvraudio_client.qti.so libvraudio.so libvr_object_engine.so libvr_sam_wrapper.so libwfdaac.so libwfdmmsrc_system.so libwfdsinksm.so

cd ../lib64
sudo chmod 0644 android.frameworks.cameraservice.common@2.0.so android.frameworks.cameraservice.device@2.0.so android.frameworks.cameraservice.service@2.0.so android.hardware.camera.common@1.0.so android.hardware.camera.device@1.0.so android.hardware.camera.device@3.2.so android.hardware.camera.device@3.3.so android.hardware.camera.device@3.4.so android.hardware.camera.device@3.5.so android.hardware.camera.provider@2.4.so android.hardware.camera.provider@2.5.so android.hardware.nfc@1.0.so android.hardware.nfc@1.1.so android.hardware.nfc@1.2.so libblurbuster.so libcameraservice.so libchromaflash.so libclang_rt.hwasan-aarch64-android.so libclearsight.so libcodec2_soft_av1dec.so libcvp_hidl.so libdce-1.1.17-mfr.so libdualcameraddm.so libfiltergenerator.so libhazebuster.so libImageSearchAPI.so libjni_blurbuster.so libjni_chromaflash.so libjni_clearsight.so libjni_dualcamera.so libjni_filtergenerator.so libjni_hazebuster.so libjni_load_serinum.so libjni_optizoom.so libjni_seestraight.so libjni_sharpshooter.so libjni_sound_effect.so libjni_stillmore.so libjni_trueportrait.so libjni_truescanner_v2.so libjni_ubifocus.so libkcmutilex.so libkcmutil.so libmiuiimageutilities.so libmtk_serialnum.so libnap.so libnqnfc_nci_jni.so libnqnfc-nci.so liboptizoom.so libseemore.so libseestraight.so libsic_helper.so libsn100nfc_nci_jni.so libsn100nfc-nci.so libstagefright_bufferpool@2.0.so libstfaceunlockocl.so libsubtitle_jni.so libtcp.so libTmsdk-2.0.10-mfr.so libTmsdk-2.0.12-mfr.so libtrueportrait.so libtruescanner.so libubifocus.so libyuv.so vendor.qti.hardware.audiohalext-utils.so vendor.qti.hardware.sigma_miracast@1.0-halimpl.so vendor.xiaomi.hardware.vibratorfeature@1.0.so libarc_layer_sgl.so libarcsoft_deflicker.so libarcsoft_wideselfie.so libcamera_960_mpbase.so libcamera_arcsoft_beautyshot.so libcamera_arcsoft_handgesture.so libcamera_beauty_mpbase.so libcamera_wideselfie_mpbase.so libcodec2_hidl@1.0.so libcodec2_soft_aacdec.so libcodec2_soft_aacenc.so libcodec2_soft_amrnbdec.so libcodec2_soft_amrnbenc.so libcodec2_soft_amrwbdec.so libcodec2_soft_amrwbenc.so libcodec2_soft_avcdec.so libcodec2_soft_avcenc.so libcodec2_soft_common.so libcodec2_soft_flacdec.so libcodec2_soft_flacenc.so libcodec2_soft_g711alawdec.so libcodec2_soft_g711mlawdec.so libcodec2_soft_gsmdec.so libcodec2_soft_h263dec.so libcodec2_soft_h263enc.so libcodec2_soft_hevcdec.so libcodec2_soft_hevcenc.so libcodec2_soft_mp3dec.so libcodec2_soft_mpeg2dec.so libcodec2_soft_mpeg4dec.so libcodec2_soft_mpeg4enc.so libcodec2_soft_opusdec.so libcodec2_soft_opusenc.so libcodec2_soft_rawdec.so libcodec2_soft_vorbisdec.so libcodec2_soft_vp8dec.so libcodec2_soft_vp8enc.so libcodec2_soft_vp9dec.so libcodec2_soft_vp9enc.so libdeflicker_jni.so libDiagService.so libdoc_photo_c++_shared.so libdoc_photo.so libdolphin.so libdrm.so libframeextension.so libfuse-lite.so libgallery_arcsoft_dualcam_refocus.so libgallery_arcsoft_portrait_lighting_c.so libgallery_arcsoft_portrait_lighting.so libgallery_mpbase.so libhandengine.arcsoft.so libjni_arcsoft_beautyshot.so libjni_wideselfie.so libmedia_codecserviceregistrant.so libmibokeh_gallery.so libntfs-3g.so libopus.so libprotobuf-cpp-full-rtti.so libqdMetaData.so libQSEEComAPI_system.so libqvrcamera_client.qti.so libqvrservice_client.qti.so libqvrservice_ov7251_hvx_tuning.so libqvrservice_ov9282_hvx_tuning.so librefocus_mibokeh.so librefocus.so libsensorslog.so libskewknob_system.so libsns_device_mode_stub.so libsnsdiaglog.so libsns_fastRPC_util.so libsns_low_lat_stream_stub.so libssc.so libstagefright_flacdec.so libvideo_extra_color_converter.so libvideo_extra_interpolator.so libvpx.so libvr_amb_engine.so libvraudio_client.qti.so libvraudio.so libvr_object_engine.so libvr_sam_wrapper.so libwfdcommonutils.so libwfdconfigutils.so libwfdmminterface.so libwfdmmsink.so libwfdrtsp.so libwfdsinksm.so libwfdsm.so libwfduibcinterface.so libwfduibcsinkinterface.so libwfduibcsink.so libwfduibcsrcinterface.so libwfduibcsrc.so libYuvWatermark.so libcom.xiaomi.camera.algojni.so libcom.xiaomi.camera.mianodejni.so libcom.xiaomi.camera.requestutil.so libffmpeg.so libjni_jpegutil_xiaomi.so libmulti-wakeup-engine.so librecord_video.so libsubtitle_jni.so libtt_effect.so libttffmpeg.so libtt_jni.so libttvebase.so libttvideoeditor.so libttvideorecorder.so libttyuv.so libvvc++_shared.so libcamera_handgesture_mpbase.so

cd ..
sudo chmod 0755 lib
sudo chmod 0755 lib64

sudo chmod -R 0755 priv-app/MiuiCamera
sudo chmod 0644 priv-app/MiuiCamera/MiuiCamera.apk
sudo chmod 0755 priv-app

cd "$PD"

# battery
sudo cp -v "$PD"/work/"$ROM"/s/system/framework/framework-res.apk "$PD"/.tools/work/g/apk/in/
sudo unzip -X "$PD"/.tools/work/g/apk/in/framework-res.apk -d "$PD"/.tools/work/g/apk/work/framework-res
sudo cp -v -p "$PD"/.tools/work/g/apk/power_profile.xml "$PD"/.tools/work/g/apk/work/framework-res/res/xml
cd "$PD"/.tools/work/g/apk/work/framework-res
sudo zip -r0 framework-res.apk *
cd "$PD"
sudo cp -v "$PD"/.tools/work/g/apk/work/framework-res/framework-res.apk "$PD"/work/"$ROM"/s/system/framework/framework-res.apk
sudo chmod 0644 "$PD"/work/"$ROM"/s/system/framework/framework-res.apk
sudo rm -rf "$PD"/.tools/work/g/apk/work/framework-res

# product
sudo cp -a -v "$PD"/.tools/work/g/product/. "$PD"/work/"$ROM"/p/
sudo chmod -R 0644 "$PD"/work/"$ROM"/p/lib*
sudo chmod 0755 "$PD"/work/"$ROM"/p/lib*

# props
"$PD"/.tools/work/g/sed/SsedB "$ROM"
"$PD"/.tools/work/g/sed/ctscust "$ROM"

"$PD"/.tools/work/g/sed/SsedP "$ROM"

"$PD"/.tools/work/g/sed/PsedB "$ROM"
"$PD"/.tools/work/g/sed/ctscustp "$ROM"

cd "$PD"/work/"$ROM"/
sudo umount s p
rm -rf s p
cd "$PD"

sudo ./zip "$ROM"
