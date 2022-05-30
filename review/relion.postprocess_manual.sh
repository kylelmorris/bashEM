#!/bin/bash
#

# Test if Relion is sourced and available
command -v relion >/dev/null 2>&1 || { echo >&2 "Relion does not appear to be installed or loaded..."; exit 1; }

# Test if Phenix is sourced and available
command -v phenix.about >/dev/null 2>&1 || { echo >&2 "Phenix does not appear to be installed or loaded..."; exit 1; }

# Test if Coot is sourced and available
command -v coot >/dev/null 2>&1 || { echo >&2 "Coot does not appear to be installed or loaded..."; exit 1; }

# Variables
half1=$1
half2=$2
apix=$3
ini=$4
inie=$5
inis=$6
MTF=$7
outdir=$8
optional=$9

# Variables test
if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] || [[ -z $5 ]] || [[ -z $6 ]] || [[ -z $7 ]] || [[ -z $8 ]]; then

  echo ""
  echo "Variables empty, usage is ${0} (1) (2) (3) (4) (5) (6) (7) (8) (9)"
  echo ""
  echo "(1) = half map 1"
  echo "(2) = half map 2"
  echo "(3) = apix"
  echo "(4) = inimask threshold"
  echo "(5) = inimask extend (px)"
  echo "(6) = inimask soften (px)"
  echo "(7) = MTF star file"
  echo "(8) = Output directory (./PostProcess)"
  echo "(9) = additional commands"
  exit

fi

# Directory and folder names
ext=$(echo ${half1##*.})
name=$(basename $half1 .${ext})
dir=$(dirname $half1)

# Output setup
note="${outdir}/postprocess_ini${ini}_e${inie}_s${inis}_note.txt"

# Save the command
echo "${0} script inputs:" > ${note}
echo "half map 1: ${half1}" >> ${note}
echo "half map 2: ${half2}" >> ${note}
echo "apix: ${apix}" >> ${note}
echo "inimask threshold: ${ini}" >> ${note}
echo "inimask extend (px): ${inie}" >> ${note}
echo "inimask soften (px): ${inis}" >> ${note}
echo "MTF star file: ${MTF}" >> ${note}
echo "Output directory: ${outdir}" >> ${note}
echo "additional commands: ${optional}" >> ${note}
echo "" >> ${note}

echo "relion_postprocess --i ${half1} --i2 ${half2} --angpix ${apix} --auto_mask --inimask_threshold ${ini} --extend_inimask ${inie} --width_mask_edge ${inis} --mtf ${MTF} --auto_bfac --o ${outdir}/postprocess_ini${ini}_e${inie}_s${inis} ${optional}" >> ${note}
echo "" >> ${note}

echo "Postprocessing running, be patient..."

# Do the postprocessing
relion_postprocess --i ${half1} --i2 ${half2} --angpix ${apix} --auto_mask --inimask_threshold ${ini} --extend_inimask ${inie} --width_mask_edge ${inis} --mtf ${MTF} --auto_bfac --o ${outdir}/postprocess_ini${ini}_e${inie}_s${inis} ${optional} > ${outdir}/postprocess_ini${ini}_e${inie}_s${inis}.out

cat ${outdir}/postprocess_ini${ini}_e${inie}_s${inis}.out

# Plot the fsc curves
relion.plot_fsc.sh ${outdir}/postprocess_ini${ini}_e${inie}_s${inis}.star

# Get the resolution
res=$(grep FINAL ${outdir}/postprocess_ini${ini}_e${inie}_s${inis}.out | awk '{print $4}')
echo "Resolution: ${res}"

# Convert the postprocessed mrc to structure factors
phenix.map_to_structure_factors "${outdir}/postprocess_ini${ini}_e${inie}_s${inis}_masked.mrc" "output_file_name=${outdir}/postprocess_ini${ini}_e${inie}_s${inis}_masked.mtz" "d_min=${res}"

# Save the command
echo "phenix.map_to_structure_factors ${outdir}/postprocess_ini${ini}_e${inie}_s${inis}_masked.mrc output_file_name=${outdir}/postprocess_ini${ini}_e${inie}_s${inis}_masked.mtz d_min=${res}" >> ${note}
echo "" >> ${outdir}/postprocess_ini${ini}_e${inie}_s${inis}.out

# Create a coot script for manual resampling
echo "set_map_sampling_rate ( 3.000)" > ${outdir}/coot.py
echo "dir = \"${outdir}\"" >> ${outdir}/coot.py
echo "make_and_draw_map_with_reso_with_refmac_params (\"${outdir}/postprocess_ini${ini}_e${inie}_s${inis}_masked.mtz\", \"/crystal/dataset/F\", \"/crystal/dataset/PHIF\", \"\", 0, 0, 0, \"Fobs:None-specified\", \"SigF:None-specified\", \"RFree:None-specified\", 0, 0, 0, -1.00, -1.00)" >> ${outdir}/coot.py
echo "export_map(0,\"${outdir}/postprocess_ini${ini}_e${inie}_s${inis}_masked_upsamp3.mrc\")" >> ${outdir}/coot.py

# Run coot to upsample the mtz and save as mrc
coot ${outdir}/coot.py

# Save the command
echo "coot ${outdir}/coot.py" >> ${outdir}/postprocess_ini${ini}_e${inie}_s${inis}.out
echo "" >> ${outdir}/postprocess_ini${ini}_e${inie}_s${inis}.out
