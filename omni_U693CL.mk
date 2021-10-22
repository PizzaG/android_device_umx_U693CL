#
# Copyright (C) 2020 The Android Open Source Project
# Copyright (C) 2020 The TWRP Open Source Project
# Copyright (C) 2020 SebaUbuntu's TWRP device tree generator
# Copyright (C) 2019-Present A-Team Digital Solutions
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product-if-exists, $(SRC_TARGET_DIR)/product/embedded.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# Inherit from U693CL device
$(call inherit-product, device/umx/U693CL/device.mk)

# Inherit some common Omni stuff.
$(call inherit-product, vendor/omni/config/common.mk)
$(call inherit-product, vendor/omni/config/gsm.mk)

PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,device/umx/U693CL/recovery/root,recovery/root)

# Device identifier. This must come after all inclusions
PRODUCT_DEVICE := U693CL
PRODUCT_NAME := omni_U693CL
PRODUCT_BRAND := Umx
PRODUCT_MODEL := U693CL
PRODUCT_MANUFACTURER := Umx
PRODUCT_RELEASE_NAME := Umx U693CL
