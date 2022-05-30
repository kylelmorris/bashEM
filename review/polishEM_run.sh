#!/bin/bash
#

options="-2 -C -r 0.5 -t 8 -a 90"

echo "This script will denoise mrc images using polishEM and the following options"
echo "polishEM ${options} input output"
echo "PolishEM is designed for denoising FIB-SEM data"
echo ""
echo "To denoise all files in current directory press Enter, or exit with ctrl+c"
read p

# Check dependancies
# Relion
command -v relion >/dev/null 2>&1 || { echo >&2 "Relion does not appear to be installed or loaded..."; exit 1; }

for f in *.mrc; do

  #Report info
  echo "Denoising file ${f} using polishEM"

  # Get file name attributes
  ext=$(echo ${f##*.})
  name=$(basename $f .${ext})
  dir=$(dirname $f)

  polishEM $options ${name}.${ext} ${name}_denoised.${ext}

done

#Tidy up
echo "Tidying up and creating final stack using Relion"

mkdir -p denoised
mv *_denoised.${ext} denoised
mkdir -p raw
mv *.${ext} raw

ls denoised/*_denoised.${ext} > list.dat
relion_star_loopheader rlnImageName > header.dat
cat header.dat list.dat > denoised.star

relion_stack_create --i denoised.star --o stack_denoised

ls raw/*.${ext} > list.dat
relion_star_loopheader rlnImageName > header.dat
cat header.dat list.dat > unprocessed.star

relion_stack_create --i unprocessed.star --o stack_unprocessed

rm -rf *.dat

#Finish
echo "Done!"
echo "Script written by Kyle Morris, MRC LMS"

echo " See https://sites.google.com/site/3demimageprocessing/polishem for further details"
