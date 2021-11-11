#!/bin/bash

make clean

export USE_CCACHE=1
export OF_MAINTAINER=PizzaG
export OF_DISABLE_MIUI_SPECIFIC_FEATURES=1
export FOX_REMOVE_AAPT=1
export OF_CHECK_OVERWRITE_ATTEMPTS=1
. build/envsetup.sh
lunch omni_U693CL-eng
mka recoveryimage

echo " Recovery Should Be Built"
echo ""
read
