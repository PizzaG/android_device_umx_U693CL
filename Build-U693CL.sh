#!/bin/bash

make clean

export PBRP_MAINTAINER=PizzaG
. build/envsetup.sh
lunch omni_U693CL-eng
mka recoveryimage

echo " Recovery Should Be Built"
echo ""
read
