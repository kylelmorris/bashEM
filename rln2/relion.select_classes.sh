#!/bin/bash
#

# Variables
stackin=$1
output=stack_selection

# Test if Relion is sourced and available
command -v relion >/dev/null 2>&1 || { echo >&2 "Relion does not appear to be installed or loaded..."; exit 1; }

echo ""
echo "Usage is $(basename $0) (1)"
echo ""
echo "(1) = *.mrcs"
echo ""

if [[ -z $1 ]] ; then
  echo ""
  echo "Location of *.mrcs needs to be specified..."
  echo ""
  exit
fi

# Directory and folder names
ext=$(echo ${stackin##*.})
name=$(basename $stackin .${ext})
dir=$(dirname $stackin)

# Make directory for class occupancy data and plots
mkdir -p ${dir}/${output}

# Copy stack into selection directory
scp -r ${stackin} ${dir}/${output}/${name}.mrcs

## Make model star file
# Make model header
relion_star_loopheader rlnReferenceImage rlnClassPriorOffsetX rlnClassPriorOffsetY > ${dir}/${output}/${name}_model_header.star
sed -i 's/data_/data_model_classes/g' ${dir}/${output}/${name}_model_header.star
# Make model datalines
imgno=$(relion_image_handler --stats --i ${dir}/${output}/${name}.mrcs | wc -l)
relion_star_datablock_stack ${imgno} ${dir}/${output}/${name}.mrcs 0.000000 0.000000 > ${dir}/${output}/${name}_model_datalines.star
# Combine header and datalines
cat ${dir}/${output}/${name}_model_header.star ${dir}/${output}/${name}_model_datalines.star > ${dir}/${output}/${name}_model.star
rm -rf ${dir}/${output}/${name}_model_header.star
rm -rf ${dir}/${output}/${name}_model_datalines.star

# Make dummy particle data.star file
echo data_ > ${dir}/${output}/${name}_data.star

# Allow user to select images from stack using relion_display
relion_display --gui --i ${dir}/${output}/${name}_model.star --allow_save --fn_imgs ${dir}/${output}/${name}_selected.star --recenter

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
