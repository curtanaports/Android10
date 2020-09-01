#!/bin/bash
PD="$PWD"

DATE=$(TZ=Asia/Kolkata date +"%d%m")

ROM="$1"

##---------------------------------------------------------##

mkdir "$PD"/out
mkdir "$PD"/out/"$ROM"
mkdir "$PD"/in
mkdir "$PD"/in/"$ROM"
mkdir "$PD"/work
mkdir "$PD"/work/"$ROM"
mv *.zip "$PD"/in/"$ROM"/

unzip -n -q -d "$PD"/out/"$ROM" "$PD"/in/"$ROM"/*.zip -x firmware-update/km4.mbn firmware-update/qupv3fw.elf firmware-update/storsec.mbn firmware-update/uefi_sec.mbn firmware-update/vbmeta.img firmware-update/xbl_config.elf firmware-update/imagefv.elf firmware-update/dtbo.img firmware-update/abl.elf firmware-update/BTFM.bin firmware-update/cmnlib64.mbn firmware-update/cmnlib.mbn firmware-update/devcfg.mbn firmware-update/dspso.bin firmware-update/hyp.mbn firmware-update/keymaster.mbn firmware-update/mdtp.img firmware-update/mdtpsecapp.mbn firmware-update/NON-HLOS.bin firmware-update/pmic.elf firmware-update/rpm.mbn firmware-update/splash.img firmware-update/tz.mbn firmware-update/xbl.elf boot.img dtbo.img vendor.* cust.*

brotli -j -v -d "$PD"/out/$ROM/system.new.dat.br "$PD"/out/$ROM/system.new.dat
.tools/sdat2img/sdat2img.py "$PD"/out/$ROM/system.transfer.list "$PD"/out/$ROM/system.new.dat "$PD"/work/"$ROM"/s-"$DATE".img

rm -rf "$PD"/out/$ROM/*

##---------------------------------------------------------##

rm -rf "$PD"/work/"$ROM"/s && mkdir "$PD"/work/"$ROM"/s
mount -o loop "$PD"/work/"$ROM"/s-"$DATE".img "$PD"/work/"$ROM"/s

rm -rf "$PD"/work/"$ROM"/s/system/etc/device_features/

# product
unzip -X "$PD"/.tools/p.zip -d "$PD"/work/"$ROM"/
mv "$PD"/work/"$ROM"/p.img "$PD"/work/"$ROM"/p-"$DATE".img
rm -rf "$PD"/work/"$ROM"/p && mkdir "$PD"/work/"$ROM"/p

# increase product image size
dd if=/dev/zero bs=1M count=1000 >> "$PD"/work/"$ROM"/p-"$DATE".img
e2fsck -f -y "$PD"/work/"$ROM"/p-"$DATE".img
resize2fs "$PD"/work/"$ROM"/p-"$DATE".img

# start masking changes
mount -o loop "$PD"/work/"$ROM"/p-"$DATE".img "$PD"/work/"$ROM"/p
rm -rf "$PD"/work/"$ROM"/p/*
cp -a -v "$PD"/work/"$ROM"/s/system/product/. "$PD"/work/"$ROM"/p/

rm -rf "$PD"/work/"$ROM"/s/system/product
rm -rf "$PD"/work/"$ROM"/s/product

cp -r -v "$PD"/.tools/work/root/. "$PD"/work/"$ROM"/s/

cp -a -v "$PD"/work/"$ROM"/s/vendor "$PD"/work/"$ROM"/s/product


cd "$PD"/work/"$ROM"/s/
chmod 0750 init.rc
chmod 0750 init.recovery.hardware.rc
chmod 0750 init.recovery.qcom.rc
chown root:2000 init.rc
chown root:2000 init.recovery.hardware.rc
chown root:2000 init.recovery.qcom.rc
chmod 0755 system

cd system
rm -rf data-app

chmod -R 0644 app/Health/lib/arm*
chmod 0755 app/Health/lib/arm*

cd bin
chmod 0755 audio_set_params btcit elliptic_recording_tool ext_logger fatal_error fsck.ntfs ghr mem_parser mifunctiontest mishow.sh mkfs.ntfs mount.ntfs odm_vib_cal procmem qmesa_parser qmesa.sh qvrdatalogger qvrservice qvrservicetest qvrservicetest64 rtspclient rtspserver strace tcpdump tcpdump_v2 tinyhostless vibrator_test hwservicemanager

chown root:2000 audio_set_params btcit elliptic_recording_tool ext_logger fatal_error fsck.ntfs ghr mem_parser mifunctiontest mishow.sh mkfs.ntfs mount.ntfs odm_vib_cal procmem qmesa_parser qmesa.sh qvrdatalogger qvrservice qvrservicetest qvrservicetest64 rtspclient rtspserver strace tcpdump tcpdump_v2 tinyhostless vibrator_test hwservicemanager

cd ..
chmod 0751 bin
chown root:2000 bin

cd etc
chmod 0644 hosts
chmod -R 0644 display
chmod 0755 display

chmod -R 0644 init
chmod 0755 init

chmod -R 0644 device_features
chmod 0755 device_features

chmod -R 0644 qvr
chmod 0755 qvr

chmod -R 0644 sensors
chmod 0755 sensors/proto
chmod 0755 sensors

chmod -R 0644 vintf
chmod 0755 vintf/manifest
chmod 0755 vintf

cd ..
chmod 0755 etc

cd lib
chmod -R 0644 rfsa
chmod 0755 rfsa/adsp
chmod 0755 rfsa

chmod 0644 android.hardware.nfc@1.0.so android.hardware.nfc@1.1.so android.hardware.nfc@1.2.so libblurbuster.so libchromaflash.so libcodec2_soft_av1dec.so libdualcameraddm.so libfiltergenerator.so libhazebuster.so libjni_blurbuster.so libjni_chromaflash.so libjni_dualcamera.so libjni_filtergenerator.so libjni_hazebuster.so libjni_load_serinum.so libjni_optizoom.so libjni_seestraight.so libjni_sharpshooter.so libjni_stillmore.so libjni_trueportrait.so libjni_truescanner_v2.so libjni_ubifocus.so libmetricslogger.so libmiuiimageutilities.so libnqnfc_nci_jni.so libnqnfc-nci.so liboptizoom.so libseemore.so libseestraight.so libsensor_calibration.so libsn100nfc_nci_jni.so libsn100nfc-nci.so libstagefright_bufferpool@2.0.so libstatssocket.so libsubtitle_jni.so libtrueportrait.so libtruescanner.so libubifocus.so vendor.qti.hardware.audiohalext-utils.so vendor.qti.hardware.sigma_miracast@1.0-halimpl.so vendor.xiaomi.hardware.vibratorfeature@1.0.so libclang_rt.ubsan_standalone-arm-android.so libcodec2_hidl@1.0.so libcodec2_soft_aacdec.so libcodec2_soft_aacenc.so libcodec2_soft_amrnbdec.so libcodec2_soft_amrnbenc.so libcodec2_soft_amrwbdec.so libcodec2_soft_amrwbenc.so libcodec2_soft_avcdec.so libcodec2_soft_avcenc.so libcodec2_soft_common.so libcodec2_soft_flacdec.so libcodec2_soft_flacenc.so libcodec2_soft_g711alawdec.so libcodec2_soft_g711mlawdec.so libcodec2_soft_gsmdec.so libcodec2_soft_h263dec.so libcodec2_soft_h263enc.so libcodec2_soft_hevcdec.so libcodec2_soft_hevcenc.so libcodec2_soft_mp3dec.so libcodec2_soft_mpeg2dec.so libcodec2_soft_mpeg4dec.so libcodec2_soft_mpeg4enc.so libcodec2_soft_opusdec.so libcodec2_soft_opusenc.so libcodec2_soft_rawdec.so libcodec2_soft_vorbisdec.so libcodec2_soft_vp8dec.so libcodec2_soft_vp8enc.so libcodec2_soft_vp9dec.so libcodec2_soft_vp9enc.so libcom.xiaomi.camera.algojni.so libcom.xiaomi.camera.mianodejni.so libDiagService.so libdolphin.so libdrm.so libeye_tracking_dsp_sample_stub.so libframeextension.so libmedia_codecserviceregistrant.so libopus.so libprotobuf-cpp-full-rtti.so libqdMetaData.so libQSEEComAPI_system.so libqvr_cam_cdsp_driver_stub.so libqvrcamera_client.qti.so libqvr_cdsp_driver_stub.so libqvr_eyetracking_plugin.so libqvrservice_client.qti.so libqvrservice_ov7251_hvx_tuning.so libqvrservice_ov9282_hvx_tuning.so libqvrservice.so libsensorslog.so libskewknob_system.so libsns_device_mode_stub.so libsnsdiaglog.so libsns_fastRPC_util.so libsns_low_lat_stream_stub.so libssc.so libvpx.so libvr_amb_engine.so libvraudio_client.qti.so libvraudio.so libvr_object_engine.so libvr_sam_wrapper.so libwfdaac.so libwfdmmsrc_system.so libwfdsinksm.so

cd ../lib64
chmod 0644 android.frameworks.cameraservice.common@2.0.so android.frameworks.cameraservice.device@2.0.so android.frameworks.cameraservice.service@2.0.so android.hardware.camera.common@1.0.so android.hardware.camera.device@1.0.so android.hardware.camera.device@3.2.so android.hardware.camera.device@3.3.so android.hardware.camera.device@3.4.so android.hardware.camera.device@3.5.so android.hardware.camera.provider@2.4.so android.hardware.camera.provider@2.5.so android.hardware.nfc@1.0.so android.hardware.nfc@1.1.so android.hardware.nfc@1.2.so libblurbuster.so libcameraservice.so libchromaflash.so libclang_rt.hwasan-aarch64-android.so libclearsight.so libcodec2_soft_av1dec.so libcvp_hidl.so libdce-1.1.17-mfr.so libdualcameraddm.so libfiltergenerator.so libhazebuster.so libImageSearchAPI.so libjni_blurbuster.so libjni_chromaflash.so libjni_clearsight.so libjni_dualcamera.so libjni_filtergenerator.so libjni_hazebuster.so libjni_load_serinum.so libjni_optizoom.so libjni_seestraight.so libjni_sharpshooter.so libjni_sound_effect.so libjni_stillmore.so libjni_trueportrait.so libjni_truescanner_v2.so libjni_ubifocus.so libkcmutilex.so libkcmutil.so libmiuiimageutilities.so libmtk_serialnum.so libnap.so libnqnfc_nci_jni.so libnqnfc-nci.so liboptizoom.so libseemore.so libseestraight.so libsic_helper.so libsn100nfc_nci_jni.so libsn100nfc-nci.so libstagefright_bufferpool@2.0.so libstfaceunlockocl.so libsubtitle_jni.so libtcp.so libTmsdk-2.0.10-mfr.so libTmsdk-2.0.12-mfr.so libtrueportrait.so libtruescanner.so libubifocus.so libyuv.so vendor.qti.hardware.audiohalext-utils.so vendor.qti.hardware.sigma_miracast@1.0-halimpl.so vendor.xiaomi.hardware.vibratorfeature@1.0.so libarc_layer_sgl.so libarcsoft_deflicker.so libarcsoft_wideselfie.so libcamera_960_mpbase.so libcamera_arcsoft_beautyshot.so libcamera_arcsoft_handgesture.so libcamera_beauty_mpbase.so libcamera_wideselfie_mpbase.so libcodec2_hidl@1.0.so libcodec2_soft_aacdec.so libcodec2_soft_aacenc.so libcodec2_soft_amrnbdec.so libcodec2_soft_amrnbenc.so libcodec2_soft_amrwbdec.so libcodec2_soft_amrwbenc.so libcodec2_soft_avcdec.so libcodec2_soft_avcenc.so libcodec2_soft_common.so libcodec2_soft_flacdec.so libcodec2_soft_flacenc.so libcodec2_soft_g711alawdec.so libcodec2_soft_g711mlawdec.so libcodec2_soft_gsmdec.so libcodec2_soft_h263dec.so libcodec2_soft_h263enc.so libcodec2_soft_hevcdec.so libcodec2_soft_hevcenc.so libcodec2_soft_mp3dec.so libcodec2_soft_mpeg2dec.so libcodec2_soft_mpeg4dec.so libcodec2_soft_mpeg4enc.so libcodec2_soft_opusdec.so libcodec2_soft_opusenc.so libcodec2_soft_rawdec.so libcodec2_soft_vorbisdec.so libcodec2_soft_vp8dec.so libcodec2_soft_vp8enc.so libcodec2_soft_vp9dec.so libcodec2_soft_vp9enc.so libdeflicker_jni.so libDiagService.so libdoc_photo_c++_shared.so libdoc_photo.so libdolphin.so libdrm.so libframeextension.so libfuse-lite.so libgallery_arcsoft_dualcam_refocus.so libgallery_arcsoft_portrait_lighting_c.so libgallery_arcsoft_portrait_lighting.so libgallery_mpbase.so libhandengine.arcsoft.so libjni_arcsoft_beautyshot.so libjni_wideselfie.so libmedia_codecserviceregistrant.so libmibokeh_gallery.so libntfs-3g.so libopus.so libprotobuf-cpp-full-rtti.so libqdMetaData.so libQSEEComAPI_system.so libqvrcamera_client.qti.so libqvrservice_client.qti.so libqvrservice_ov7251_hvx_tuning.so libqvrservice_ov9282_hvx_tuning.so librefocus_mibokeh.so librefocus.so libsensorslog.so libskewknob_system.so libsns_device_mode_stub.so libsnsdiaglog.so libsns_fastRPC_util.so libsns_low_lat_stream_stub.so libssc.so libstagefright_flacdec.so libvideo_extra_color_converter.so libvideo_extra_interpolator.so libvpx.so libvr_amb_engine.so libvraudio_client.qti.so libvraudio.so libvr_object_engine.so libvr_sam_wrapper.so libwfdcommonutils.so libwfdconfigutils.so libwfdmminterface.so libwfdmmsink.so libwfdrtsp.so libwfdsinksm.so libwfdsm.so libwfduibcinterface.so libwfduibcsinkinterface.so libwfduibcsink.so libwfduibcsrcinterface.so libwfduibcsrc.so libYuvWatermark.so libcom.xiaomi.camera.algojni.so libcom.xiaomi.camera.mianodejni.so libcom.xiaomi.camera.requestutil.so libffmpeg.so libjni_jpegutil_xiaomi.so libmulti-wakeup-engine.so librecord_video.so libsubtitle_jni.so libtt_effect.so libttffmpeg.so libtt_jni.so libttvebase.so libttvideoeditor.so libttvideorecorder.so libttyuv.so libvvc++_shared.so libcamera_handgesture_mpbase.so

cd ..
chmod 0755 lib
chmod 0755 lib64

chmod -R 0755 priv-app/MiuiCamera
chmod 0644 priv-app/MiuiCamera/MiuiCamera.apk
chmod 0755 priv-app

cd "$PD"

# battery ===========================================================
mkdir "$PD"/.tools/work/apk/in/
mkdir "$PD"/.tools/work/apk/work/
cp -v "$PD"/work/"$ROM"/s/system/framework/framework-res.apk "$PD"/.tools/work/apk/in/
unzip -X "$PD"/.tools/work/apk/in/framework-res.apk -d "$PD"/.tools/work/apk/work/framework-res
cp -v -p "$PD"/.tools/work/apk/power_profile.xml "$PD"/.tools/work/apk/work/framework-res/res/xml
cd "$PD"/.tools/work/apk/work/framework-res
zip -r0 framework-res.apk *
cd "$PD"
cp -v "$PD"/.tools/work/apk/work/framework-res/framework-res.apk "$PD"/work/"$ROM"/s/system/framework/framework-res.apk
chmod 0644 "$PD"/work/"$ROM"/s/system/framework/framework-res.apk
rm -rf "$PD"/.tools/work/apk/work/framework-res

# haptic ===========================================================

cp -v "$PD"/work/"$ROM"/s/system/priv-app/MiuiSystemUI/MiuiSystemUI.apk "$PD"/.tools/work/apk/in/
unzip -X "$PD"/.tools/work/apk/in/MiuiSystemUI.apk -d "$PD"/.tools/work/apk/work/MiuiSystemUI
java -jar "$PD"/.tools/work/apk/bak.jar d "$PD"/.tools/work/apk/work/MiuiSystemUI/classes.dex -o "$PD"/.tools/work/apk/work/bak

charge="$PD"/.tools/work/apk/work/bak/com/android/keyguard/charge/rapid/RapidChargeView.smali
sshot="$PD"/.tools/work/apk/work/bak/com/android/systemui/screenshot/GlobalScreenshot.smali

sed -i 's|    const-class p2, Lcom/android/systemui/HapticFeedBackImpl;||g' "$charge"
sed -i 's|    invoke-static {p2}, Lcom/android/systemui/Dependency;->get(Ljava/lang/Class;)Ljava/lang/Object;||g' "$charge"
sed -i 's|    move-result-object p2||g' "$charge"
sed -i 's|    check-cast p2, Lcom/android/systemui/HapticFeedBackImpl;||g' "$charge"
sed -i 's|    const/16 v0, 0x4a||g' "$charge"
sed -i 's|    invoke-virtual {p2, v0, p1, p1}, Lcom/android/systemui/HapticFeedBackImpl;->extHapticFeedback(IZI)V||g' "$charge"

sed '
    N;
    /^\n$/d;
    P;
    D
' $charge > "$PD"/.tools/work/apk/work/bak/com/android/keyguard/charge/rapid/temp

cp "$PD"/.tools/work/apk/work/bak/com/android/keyguard/charge/rapid/temp "$PD"/.tools/work/apk/work/bak/com/android/keyguard/charge/rapid/RapidChargeView.smali
rm "$PD"/.tools/work/apk/work/bak/com/android/keyguard/charge/rapid/temp


sed -i 's|    new-instance v1, Lmiui/util/HapticFeedbackUtil;||g' "$sshot"
sed -i 's|    invoke-direct {v1, v2, v3}, Lmiui/util/HapticFeedbackUtil;-><init>(Landroid/content/Context;Z)V||g' "$sshot"
sed -i 's|    const/16 v2, 0x55||g' "$sshot"
sed -i 's|    invoke-virtual {v1, v2}, Lmiui/util/HapticFeedbackUtil;->performExtHapticFeedback(I)Z||g' "$sshot"

sed '
    N;
    /^\n$/d;
    P;
    D
' $sshot > "$PD"/.tools/work/apk/work/bak/com/android/systemui/screenshot/temp
cp "$PD"/.tools/work/apk/work/bak/com/android/systemui/screenshot/temp "$PD"/.tools/work/apk/work/bak/com/android/systemui/screenshot/GlobalScreenshot.smali
rm "$PD"/.tools/work/apk/work/bak/com/android/systemui/screenshot/temp

cd "$PD"/.tools/work/apk/work/
java -jar "$PD"/.tools/work/apk/smali.jar a "$PD"/.tools/work/apk/work/bak -o "$PD"/.tools/work/apk/work/classes.dex
mv "$PD"/.tools/work/apk/work/classes.dex "$PD"/.tools/work/apk/work/MiuiSystemUI/
cd "$PD"/.tools/work/apk/work/MiuiSystemUI
zip -r0 MiuiSystemUI.apk *
cd "$PD"
cp -v "$PD"/.tools/work/apk/work/MiuiSystemUI/MiuiSystemUI.apk "$PD"/work/"$ROM"/s/system/priv-app/MiuiSystemUI/MiuiSystemUI.apk
chmod 0644 "$PD"/work/"$ROM"/s/system/priv-app/MiuiSystemUI/MiuiSystemUI.apk
rm -rf "$PD"/.tools/work/apk/work/MiuiSystemUI
rm -rf "$PD"/.tools/work/apk/work/bak


# product ===========================================================

cp -r -v "$PD"/.tools/work/product/app/NetworkStackOverlay "$PD"/work/"$ROM"/p/app/
cp -v "$PD"/.tools/work/product/etc/permissions/privapp-permissions-google.xml "$PD"/work/"$ROM"/p/etc/permissions/
cp -r -v "$PD"/.tools/work/product/priv-app/. "$PD"/work/"$ROM"/p/priv-app/
cp -v "$PD"/.tools/work/product/build.prop "$PD"/work/"$ROM"/p/
cp -r -v "$PD"/.tools/work/product/lib* "$PD"/work/"$ROM"/p/

cd "$PD"/work/"$ROM"/p/
chmod 0644 app/NetworkStackOverlay/NetworkStackOverlay.apk
chmod 0755 app/NetworkStackOverlay
chmod 0755 app
chown -R root:root app

chmod -R 0644 priv-app/Hotword*
chmod 0755 priv-app/Hotword*
chmod 0755 priv-app
chown -R root:root priv-app

chmod 0644 etc/permissions/privapp-permissions-google.xml
chmod 0755 etc/permissions
chown -R root:root etc/permissions
chmod 0755 etc
chown root:root etc


chmod -R 0644 lib*
chmod 0755 lib*

cd "$PD"
# props
"$PD"/.tools/work/sed/SsedB "$ROM"
"$PD"/.tools/work/sed/ctscust "$ROM"

"$PD"/.tools/work/sed/SsedP "$ROM"

"$PD"/.tools/work/sed/PsedB "$ROM"
"$PD"/.tools/work/sed/ctscustp "$ROM"

umount "$PD"/work/"$ROM"/s "$PD"/work/"$ROM"/p
rm -rf "$PD"/work/"$ROM"/s "$PD"/work/"$ROM"/p

./zip.sh "$ROM"
