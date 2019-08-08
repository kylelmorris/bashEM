#!/bin/bash
#

bin=$1

if [[ -z ${bin} ]] ; then
  bin=1
fi

echo "Will execute e2proc2d.py conversion with binning factor: ${bin}"
echo "Press Enter to continue or ctrl-c to quit"
read p

module load eman2

e2proc2d.py *.tif @.png --fouriershrink ${bin} --fixintscaling sane --outmode int8

mkdir tif
mkdir png

mv *tif tif
mv *png png
