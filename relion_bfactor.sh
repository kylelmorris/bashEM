#!/bin/bash
#

mapin=$1
mapout=$2
apix=$3
BF=$4

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] ; then
  echo ""
  echo "Variables empty, usage is relion_bfactor.sh (1) (2) (3) (4)"
  echo ""
  echo "(1) = mapin"
  echo "(2) = mapout"
  echo "(3) = apix"
  echo "(4) = b-factor (A)"
  echo ""

  exit
fi

echo ""
echo "Applying b-factor of ${BF} to ${mapin} using relion_image_handler"
echo ""

relion_image_handler --i $mapin --o $mapout --angpix $apix --bfactor $BF

echo ""
echo "Saved map to file: ${mapout}"
# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
