# TWRP standard device files for Qualcomm SoCs

This device tree is made for Qualcomm devices which need working decryption in TWRP. It includes the necessary services and prepdecrypt script so that these do not need to be included in the device tree.

## Prerequisites
- TWRP device tree with necessary vendor service binaries and dependencies<sup>*</sup> already included
  ```
  FDE binaries: qseecomd, keymaster
  FBE binaries: FDE binaries + gatekeeper (Pixel devices also require weaver binaries)
  ```
  ><sup>*</sup> To find the necessary dependencies for the above binaries, a tool like @that1's [ldcheck](https://github.com/that1/ldcheck) can be used (more info at bottom of this file).
- init.recovery.$(ro.hardware).rc file in device tree with symlink for bootdevice included
  ```
  symlink /dev/block/platform/soc/${ro.boot.bootdevice} /dev/block/bootdevice
  ```
**NOTES:**
- In the Android 8.1 & 9.0 trees, the binaries should be placed in the recovery ramdisk (recovery/root) in the same location as in the stock ROM, i.e. vendor/bin(/hw).
- In Android 10+ trees, the binaries should be placed in system/bin.

## TWRP Common Decryption files
To include these files for your device, the following BoardConfig flags should be used (only one flag is needed in either case, not both):
### FDE Devices
- BOARD_USES_QCOM_DECRYPTION := true
### FBE Devices
- BOARD_USES_QCOM_FBE_DECRYPTION := true
### Other Device Tree Updates
The packages will need to be added to the device tree device.mk as indicated below:
```
PRODUCT_PACKAGES += \
    qcom_decrypt \
    qcom_decrypt_fbe
```
Only the `qcom_decrypt` package should be included for FDE devices, and both should be included for FBE devices.

To import the decryption rc files into your device tree, add this line to your `init.recovery.$(ro.hardware).rc` file:
```
import /init.recovery.qcom_decrypt.rc
```

If you forget to add the above import, the build tree will add it for you if it can find the `init.recovery.qcom.rc` file. Otherwise, there will be a warning near the end of the build system output that the import needs to be added.

If for some reason these scripts do not work for you, increase the loglevel to `2` in [prepdecrypt.sh](https://github.com/TeamWin/android_device_qcom_twrp-common/blob/android-10/crypto/system/bin/prepdecrypt.sh#L22) and review the additional logging in the recovery.log to see where the process is failing.

## Example Device Trees
- android-8.1: [HTC U12+](https://github.com/TeamWin/android_device_htc_ime/tree/android-8.1/recovery/root)
- android-9.0: [ASUS ROG Phone II](https://github.com/CaptainThrowback/android_device_asus_I001D/tree/android-9.0/recovery/root)
- android-10: ASUS ROG Phone 3 ([common tree](https://github.com/TeamWin/android_device_asus_sm8250-common/tree/android-10/recovery/root)/[device tree](https://github.com/TeamWin/android_device_asus_I003D))
- android-11: ASUS ZenFone 8 ([common tree](https://github.com/TeamWin/android_device_asus_sm8350-common/tree/android-11/recovery/root)/[device tree](https://github.com/TeamWin/android_device_asus_I006D))


### Using ldcheck to find dependencies
The easiest way to find dependencies for the blobs you add from your device's vendor partition is using the ldcheck Python script. The syntax for using the script is below:
```
usage: ldcheck [-h] [-p PATH] [-r] [-a] [-d] FILE [FILE ...]

Check dynamic linkage consistency.

positional arguments:
  FILE                  a dynamically linked executable or library.

optional arguments:
  -h, --help            show this help message and exit
  -p PATH, --path PATH  Search path for libraries (use like LD_LIBRARY_PATH)
  -r, --resolved        Print resolved symbols. By default only unresolved symbols are printed.
  -a, --alldefined      Print all defined symbols
  -d, --demangle        Demangle C++ names
```
The best way to determine what dependencies are missing from TWRP is to run the script on the blobs on the $OUT folder of a completed recovery build.
By default TWRP includes many of the necessary dependencies in the recovery build, so typically you'll only need to add dependencies found in the vendor folder/partition of your device.
NOTE: On Android 10+ devices, additional dependencies from system/apex may be required.

For example, if you added qseecomd to your build, and you want to confirm that you have all of the necessary dependencies included for it, after the TWRP build is complete, you can run:
```
cd $OUT/recovery/root
```
Android 8.1/9.0:
```
ldcheck -p sbin:vendor/lib64 -d vendor/bin/qseecomd
```
Android 10+:
```
ldcheck -p system/lib64:vendor/lib64 -d system/bin/qseecomd
```
The output will look like this, if all dependencies are met (example from Android 10 tree):
```
libs: ['system/bin/qseecomd', 'system/lib64/libcutils.so', 'system/lib64/libutils.so', 'system/lib64/liblog.so', 'vendor/lib64/libQSEEComAPI.so', 'vendor/lib64/libdrmfs.so', 'system/lib64/libc++.so', 'system/lib64/libc.so', 'system/lib64/libm.so', 'system/lib64/libdl.so', 'system/lib64/libbase.so', 'system/lib64/libprocessgroup.so', 'system/lib64/libvndksupport.so', 'system/lib64/libion.so', 'vendor/lib64/libdiag.so', 'system/lib64/libxml2.so', 'system/lib64/ld-android.so', 'system/lib64/libcgrouprc.so', 'system/lib64/libdl_android.so', 'system/lib64/libandroidicu.so', 'system/lib64/libicuuc.so', 'system/lib64/libicui18n.so']
unused: {'system/lib64/libm.so', 'vendor/lib64/libdiag.so', 'system/lib64/libandroidicu.so', 'system/lib64/libprocessgroup.so', 'system/lib64/libicui18n.so', 'vendor/lib64/libQSEEComAPI.so', 'system/lib64/libdl_android.so', 'system/lib64/libutils.so', 'vendor/lib64/libdrmfs.so', 'system/lib64/libion.so', 'system/lib64/libxml2.so', 'system/lib64/libicuuc.so', 'system/lib64/libcgrouprc.so'}
```
If a dependency is missing, you'll see something like this:
```
readelf: Error: 'libQSEEComAPI.so': No such file
readelf: Error: 'libdrmfs.so': No such file
libs: ['system/bin/qseecomd', 'system/lib64/libcutils.so', 'system/lib64/libutils.so', 'system/lib64/liblog.so', 'libQSEEComAPI.so', 'libdrmfs.so', 'system/lib64/libc++.so', 'system/lib64/libc.so', 'system/lib64/libm.so', 'system/lib64/libdl.so', 'system/lib64/libbase.so', 'system/lib64/libprocessgroup.so', 'system/lib64/libvndksupport.so', 'system/lib64/ld-android.so', 'system/lib64/libcgrouprc.so', 'system/lib64/libdl_android.so']
nm: 'libQSEEComAPI.so': No such file
nm: 'libdrmfs.so': No such file
nm: 'libQSEEComAPI.so': No such file
nm: 'libdrmfs.so': No such file
unused: {'libQSEEComAPI.so', 'system/lib64/libutils.so', 'system/lib64/libdl_android.so', 'system/lib64/libcgrouprc.so', 'libdrmfs.so', 'system/lib64/libprocessgroup.so', 'system/lib64/libm.so'}
```
That output indicates that libQSEEComAPI.so and libdrmfs.so are missing as dependencies, so those should be added to the appropriate location and then ldcheck should be run again to make sure those inclusions don't lead to additional missing dependencies or symbols.
It's best to run ldcheck on every vendor file that you include, otherwise any of them can lead to a broken decryption cycle.

### Troubleshooting/Debugging
If you have issues getting decryption to work on your device, you can enable debug logging for prepdecrypt by adding the following code to the `on init` section of your `init.recovery.$(ro.hardware).rc` file:
```
setprop prepdecrypt.loglevel 2
```
The additional logging will output to the recovery log and you'll be able to see everything that is detected at every step of the process. The additional logging will include `DEBUG`.

By default, the script will only set the patch level on devices without a recovery partition, and only if recovery is booted directly and not via fastboot boot. If you want to force the script to always set the patch level and override the automatic detection, then you can add the following code to the `on init` section of your `init.recovery.$(ro.hardware).rc` file:
```
setprop prepdecrypt.setpatch true
```
(you can also force the script to never set the patch level to match system by setting the above override prop to `false`)

### Property Triggers
When prepdecrypt sets OS version and patch level, the script will temporary mount system and vendor to `/s` and `/v`, respectively. Props will be set to indicate that this mounting has taken place, as indicated below:
```
prepdecrypt.system_mounted
prepdecrypt.vendor_mounted
(1 = mounted, 0 = unmounted)
```
These values can be used as `on property` triggers in your `init.recovery.$(ro.hardware).rc` file if you have other operations to perform that require system or vendor to be mounted.