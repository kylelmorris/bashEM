#!/bin/bash
#

# Variables
stackin=$1

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
mkdir -p ${dir}/stack_selection

# Copy stack into selection directory
scp -r ${stackin} ${dir}/stack_selection/${name}.mrcs

## Make model star file
# Make model header
relion_star_loopheader _rlnReferenceImage _rlnClassPriorOffsetX _rlnClassPriorOffsetY > ${dir}/${name}_model_header.star
sed -i 's/data_/data_model_classes/g' ${dir}/${name}_model_header.star
# Make model datalines
imgno=$(relion_image_handler --stats --i ${dir}/stack_selection/${name}.mrcs | wc -l)
relion_star_datablock_stack ${imgno} ${name}.mrcs 0.000000 0.000000 > ${dir}/${name}_model_datalines.star
# Combine header and datalines
cat ${dir}/${name}_model_header.star ${dir}/${name}_model_datalines.star > ${dir}/${name}_model.star
rm -rf ${dir}/${name}_model_header.star
rm -rf ${dir}/${name}_model_datalines.star

# Make dummy particle data.star file
echo data_ > ${dir}/${name}_data.star

# Allow user to select images from stack using relion_display
relion_display --gui --i ${dir}/${name}_model.star --allow_save --fn_imgs ${dir}/stack_selection/stack_selection.star --recenter

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
