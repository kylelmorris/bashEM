#!/bin/bash
#

mapin=$1
mapout=$2

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, check input"
  echo ""
  echo "(1) = map in"
  echo "(2) = map out"
  echo ""

  exit

fi


source_e2

# Remove negative density from cryo-EM maps
e2proc3d.py $mapin $mapout --process=threshold.belowtozero

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
