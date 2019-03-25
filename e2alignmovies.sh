#!/usr/bin/env bash
#

echo "This script is designed to be run in a directory containing movies from your microscope session."
echo ""
echo "Exit at any point and restart, it should pick up where it left off"
echo "Run e2display.py in this location to inspect micrographs or open png in Fiji"
echo ""
echo "Enter the file extension for your movies, without the ."
echo "Press Enter to continue or ctrl-c to quit"
read type

# Test if eman2 is sourced and available
command -v e2projectmanager.py >/dev/null 2>&1 || { echo >&2 "Eman2 does not appear to be installed or sourced..."; exit 1; }

# Make a directory for png files
mkdir -p micrographs_png

# Get number of files
fileno=$(ls *.${type} | wc -l | awk "{print $1}")

i=0
runtime=60
# Loop through files
for f in *.${type}; do

  # Get file name attributes
  ext=$(echo ${f##*.})
  name=$(basename $f .${ext})
  dir=$(dirname $f)

  # Do a time estimation because it's fun
  timeest=$(echo "scale=2; (${fileno}-${i})*${runtime}" | bc)

  # Do the motion correction
  echo "###########################################"
  echo "Motion correcting ${f}"
  k=$(($i+1))
  echo "Working on file ${k}/${fileno}"
  echo "Estimated time remaining (secs): ${timeest}"
  echo ""

  start=`date +%s`

  # Only work on files that haven't been processed
  if [[ -f "./micrographs_png/${name}_bin4.png" ]]; then
    echo "Processing complete for ${name}, skipping..."
  else
    e2ddd_external.py ${f} --program=imod_alignframes --device=cpu --mc2_rotgain=0 --mc2_flipgain=0 --imod_rotflipgain=0 --device_num=0 --verbose=0
    rm -rf ./micrographs_mrc/${name}_ali.mrc~
    e2proc2d.py --outmode int8 --fouriershrink 4 ./micrographs_mrc/${name}_ali.mrc ./micrographs_png/${name}_bin4.png
  fi

  end=`date +%s`
  runtime=$((end-start))
  echo ""
  echo "Execution took (secs): ${runtime}"
  echo "###########################################"
  echo ""

  # Advance the Loop
  i=$(($i+1))
done

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
