#!/bin/bash
#

apix=$1
bf=$2
dmin=$3
flip=$4
resize=$5

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]]; then

  echo ""
  echo "Variables empty, usage is ${0} (1) (2) (3) (4) (5)"
  echo ""
  echo "(1) = Pixel size"
  echo "(2) = Map b-factor (as measured by Relion)"
  echo "(3) = Resolution"
  echo "(4) = zflip (y/n)"
  echo "(5) = box resize (px) (optional)"
  exit

fi

file=$(ls postprocess*.mrc)

# check is postprocessing map exists
if [[ -f $file ]] ; then
  mapin=$(ls postprocess*)
  ext=$(echo ${mapin##*.})
  name=$(basename $mapin .${ext})
  dir=$(dirname $mapin)
  echo ""
  echo "Success! ${mapin} exists, continuing..."
  echo "Enter to continue or ctrl-c to exit."
  read p
else
  echo ""
  echo "No postprocess map found, exiting..."
  exit
fi

# zflip if necessary
if [[ $flip == y ]] ; then
  printf "flipZ of map....\n"
  relion_image_handler --i ${mapin} --o ${name}_flipZ.${ext} --flipZ
  mapin=${name}_flipZ.${ext}
  mapout=$(basename $mapin .mrc)
fi

if [[ $flip == n ]] ; then
  mapin=${mapin}
  mapout=$(basename $mapin .mrc)
fi

# Resize map boxes if necessary
if [[ -z $resize ]] ; then
  echo "No map resizing requested"
else
  mapout=$(echo "${mapout}_${resize}px")
  echo "Resizing input map to ${resize} pixels"
  relion_image_handler --i ${mapin} --o ${mapout}.mrc --angpix $apix --new_box $resize
  mapin=$(echo ${mapout}.mrc)
fi

# Create an output folder
outdir="bfactor_series"
mkdir -p ${outdir}

# invert bfactor for unsharpening
nosharp=$(echo "scale=0;${bf}*-1" | bc)
echo ""
echo "Applying b-factor of ${nosharp} to create unsharpened map and structrue factors..."
echo ""

# Make unsharpened map
printf "Making map with 0A sharpening\n"
relion_image_handler --i ${mapin} --o ${outdir}/${mapout}_BF-0A.mrc --angpix $apix --bfactor $nosharp

# Round b-factor number
autobf=$(echo "scale=0;${bf}/1" | bc)
echo ""
echo "Applying b-factor of ${autobf} to create optimal global sharpened map and structrue factors..."
echo ""

# Make maps sharpened by autoBF level set by relion
printf "Making map with auto BF sharpening\n"
relion_image_handler --i ${outdir}/${mapout}_BF-0A.mrc --o ${outdir}/${mapout}_BF${autobf}A.mrc --angpix $apix --bfactor ${bf}

echo ""
echo "Applying systematic b-factors of -50, -100, -150 and -250..."
echo ""

# Make sharpen map series
printf "Making map with -50A sharpening\n"
relion_image_handler --i ${outdir}/${mapout}_BF-0A.mrc --o ${outdir}/${mapout}_BF-50A.mrc --angpix $apix --bfactor -50
printf "Making map with -100A sharpening\n"
relion_image_handler --i ${outdir}/${mapout}_BF-0A.mrc --o ${outdir}/${mapout}_BF-100A.mrc --angpix $apix --bfactor -100
printf "Making map with -150A sharpening\n"
relion_image_handler --i ${outdir}/${mapout}_BF-0A.mrc --o ${outdir}/${mapout}_BF-150A.mrc --angpix $apix --bfactor -150
printf "Making map with -200A sharpening\n"
relion_image_handler --i ${outdir}/${mapout}_BF-0A.mrc --o ${outdir}/${mapout}_BF-200A.mrc --angpix $apix --bfactor -200
printf "Making map with -250A sharpening\n"
relion_image_handler --i ${outdir}/${mapout}_BF-0A.mrc --o ${outdir}/${mapout}_BF-250A.mrc --angpix $apix --bfactor -250

# Make mtz structure factor files
printf "Making map structure factors with auto BF sharpening\n"
phenix.map_to_structure_factors ${outdir}/${mapout}_BF${autobf}A.mrc output_file_name=${outdir}/${mapout}_BF${autobf}A.mtz d_min=${dmin}
printf "Making map structure factors with -0A sharpening\n"
phenix.map_to_structure_factors ${outdir}/${mapout}_BF-0A.mrc output_file_name=${outdir}/${mapout}_BF-0A.mtz d_min=${dmin}
printf "Making map structure factors with -50A sharpening\n"
phenix.map_to_structure_factors ${outdir}/${mapout}_BF-50A.mrc output_file_name=${outdir}/${mapout}_BF-50A.mtz d_min=${dmin}
printf "Making map structure factors with -100A sharpening\n"
phenix.map_to_structure_factors ${outdir}/${mapout}_BF-100A.mrc output_file_name=${outdir}/${mapout}_BF-100A.mtz d_min=${dmin}
printf "Making map structure factors with -150A sharpening\n"
phenix.map_to_structure_factors ${outdir}/${mapout}_BF-150A.mrc output_file_name=${outdir}/${mapout}_BF-150A.mtz d_min=${dmin}
printf "Making map structure factors with -200A sharpening\n"
phenix.map_to_structure_factors ${outdir}/${mapout}_BF-200A.mrc output_file_name=${outdir}/${mapout}_BF-200A.mtz d_min=${dmin}
printf "Making map structure factors with -250A sharpening\n"
phenix.map_to_structure_factors ${outdir}/${mapout}_BF-250A.mrc output_file_name=${outdir}/${mapout}_BF-250A.mtz d_min=${dmin}

printf "Making map structure factors with auto BF sharpening\n"
phenix.map_to_structure_factors postprocess_masked.mrc output_file_name=postprocess_masked.mtz d_min=${dmin}

# relion_postprocess_make_mtz.out
echo "relion_postprocess_make_vol_series paramters" > ${outdir}/relion_postprocess_make_vol_series.out
echo "apix:" $1 >> ${outdir}/relion_postprocess_make_vol_series.out
echo "b-factor (measured by relion):" $2 >> ${outdir}/relion_postprocess_make_vol_series.out
echo "resolution:" $3 >> ${outdir}/relion_postprocess_make_vol_series.out
echo "zflip:" $4 >> ${outdir}/relion_postprocess_make_vol_series.out

echo ""
echo "Done!"

# Ask user if they want to perform local sharpening with phenix.autosharpen
echo "Do you want to perform local sharpening as well? y/n"
read p
if [ $p == y ] ; then
  echo "Performing global and local optimal b-factor sharpening with phenix.autosharpen..."
  mkdir autosharpen.global
  mkdir autosharpen.local
  phenix.auto_sharpen ${mapin} resolution=${dmin} local_sharpening=False output_directory=${outdir}/autosharpen.global
  phenix.auto_sharpen ${mapin} resolution=${dmin} local_sharpening=True output_directory=${outdir}/autosharpen.local
else
  echo "Skipping global and local optimal b-factor sharpening..."
fi

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
