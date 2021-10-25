# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from U693CL device
$(call inherit-product, $(LOCAL_PATH)/device.mk)

PRODUCT_BRAND := umx
PRODUCT_DEVICE := U693CL
PRODUCT_MANUFACTURER := umx
PRODUCT_NAME := lineage_U693CL
PRODUCT_MODEL := U693CL

PRODUCT_GMS_CLIENTID_BASE := android-umx
TARGET_VENDOR := umx
TARGET_VENDOR_PRODUCT_NAME := U693CL
PRODUCT_BUILD_PROP_OVERRIDES += PRIVATE_BUILD_DESC="U693CL-user 9 U693CL_01.02.03 210817 release-keys"

# Set BUILD_FINGERPRINT variable to be picked up by both system and vendor build.prop
BUILD_FINGERPRINT := Umx/U693CL/U693CL:9/U693CL_01.02.03/210817:user/release-keys
