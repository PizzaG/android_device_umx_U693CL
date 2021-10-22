#!/bin/bash

make clean
. build/envsetup.sh
lunch omni_U693CL-eng
mka recoveryimage

echo " Recovery Should Be Built"
echo ""
read
