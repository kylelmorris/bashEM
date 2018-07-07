#!/bin/bash
#

# A script to automate mask postprocessing optimisation in Relion


in=$1
apix=$2
MTF=$3
ex=$4
soft=$5
inimin=$6
inimax=$7
inistep=$8

echo "$(basename $0) (input) (apix) (MTF) (ex) (soft) (inimin) (inimax) (inistep)"
echo ""
echo "script: $(basename $0)"
echo "input:    $1"
echo "apix:     $2"
echo "MTF:      $3"
echo "extend:   $4"
echo "soften:   $5"
echo "ini min:  $6"
echo "ini max:  $7"
echo "ini step: $8"
echo ""
echo "output:   PostProcess/relion_postprocess_optimise"
echo "Enter to continue or ctrl-c"
read p
echo ""

mkdir -p PostProcess/relion_postprocess_optimise

i=$inimin

while [ "$(bc <<< "$i < $inimax")" == "1" ] ; do

  out="postprocess_ini${i}_e${ex}_s${soft}"
  echo ""
  echo ">>> relion_postprocess --i $in --o PostProcess/relion_postprocess_optimise/$out --auto_mask --mtf $MTF --auto_bfac --extend_inimask $ex --width_mask_edge $soft --inimask_threshold $i --angpix $apix > PostProcess/relion_postprocess_optimise/postprocess_ini${i}_e${ex}_s${soft}.out"
  echo ""
  relion_postprocess --i $in --o PostProcess/relion_postprocess_optimise/$out --auto_mask --mtf $MTF --auto_bfac --extend_inimask $ex --width_mask_edge $soft --inimask_threshold $i --angpix $apix 2>&1 | tee PostProcess/relion_postprocess_optimise/postprocess_ini${i}_e${ex}_s${soft}.out
  i=$(bc <<< "$i+$inistep")

done
