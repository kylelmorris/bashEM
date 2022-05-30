#!/bin/bash
#

# Test if Relion is sourced and available
command -v relion >/dev/null 2>&1 || { echo >&2 "Relion does not appear to be installed or loaded..."; exit 1; }

mapin=$1
mapout=$2
apix=$3
LP=$4

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] ; then
  echo ""
  echo "Variables empty, usage is relion_lowpass.sh (1) (2) (3) (4)"
  echo ""
  echo "(1) = mapin"
  echo "(2) = mapout"
  echo "(3) = apix"
  echo "(4) = low-pass filter (A)"
  echo ""

  exit
fi

echo ""
echo "Applying low pass filter of ${LP} to ${mapin} using relion_image_handler"
echo ""

relion_image_handler --i $mapin --o $mapout --angpix $apix --lowpass $LP

echo ""
echo "Saved map to file: ${mapout}"
echo "Done!"
echo ""
