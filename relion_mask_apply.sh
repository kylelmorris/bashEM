#!/bin/bash
#

map=$1
mask=$2

echo "Usage relion_mask_apply.sh (map.mrc) (mask.mrc)"
echo "Enter or ctrl-c"
echo ""
read p

file=$(basename $map .mrc)

echo "+++ relion_image_handler --i $map --multiply $mask --o ${file}_masked.mrc"
relion_image_handler --i $map --multiply $mask --o ${file}_masked.mrc

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
