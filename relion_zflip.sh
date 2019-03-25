#!/bin/bash
#

mapin=$1

if [[ -z $1 ]] ; then

  echo ""
  echo "Variables empty, usage is ${0} (1)"
  echo ""
  echo "(1) = mapin"
  exit

fi

mapout=$(basename $mapin .mrc)

# Make flipZ map
printf "Making zflip map\n"
relion_image_handler --i ${mapin} --o ${mapout}_flipZ.mrc --flipZ
printf "Done!\n"

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
