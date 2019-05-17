#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of California Berkeley, 2016
#
# This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
############################################################################

# Script to extract defocus values from relion star file and output in simple2.1 format
# Assumes you have a single stack and star file from relion ready for phase flipping in Simple


if [[ -z $1 ]] | [[ -z $2 ]] ; then
  echo ""
  echo "Variables empty, usage is relion_star_to_simple_ctf (1) (2)"
  echo ""
  echo "(1) = star file"
  echo "(2) = output dirctory name"
  echo ""
  exit
fi

## Input star file
starin=$1
name=$(basename $starin .star)
out=$name
outdir=$2
simpledir="./Simple/Extract"

###############################################################################
# Are dependancies present?
###############################################################################

rlnexe=$(which relion)
simpleexe=$(which simple)

if [[ -z $rlnexe ]] ; then
  echo "Relion not installed or sourced..."
  echo "Exiting"
  exit
else
  echo "Relion executable found:"
  echo $rlnexe
fi

if [[ -z $simpleexe ]] ; then
  echo "Simple not installed or sourced..."
  echo "Exiting"
  exit
else
  echo "Simple executable found:"
  echo $simpleexe
fi

###############################################################################
# Get column number and data for rlnMicrographName from starin
###############################################################################

micnamecol1=$(grep "rlnMicrographName" $starin | awk '{print $2}' | sed 's/#//g')
# Get columns rlnDefocusU, rlnDefocusV, rlnDefocusAngle from starin
defUcol1=$(grep "rlnDefocusU" $starin | awk '{print $2}' | sed 's/#//g')
defVcol1=$(grep "rlnDefocusV" $starin | awk '{print $2}' | sed 's/#//g')
defAcol1=$(grep "rlnDefocusAngle" $starin | awk '{print $2}' | sed 's/#//g')
# Get pixel size and mag from starin
dstepcol1=$(grep "rlnDetectorPixelSize" $starin | awk '{print $2}' | sed 's/#//g')
magcol1=$(grep "rlnMagnification" $starin | awk '{print $2}' | sed 's/#//g')
# Get microscope parameters
kvcol1=$(grep "rlnVoltage" $starin | awk '{print $2}' | sed 's/#//g')
cscol1=$(grep "rlnSphericalAberration" $starin | awk '{print $2}' | sed 's/#//g')
ampcol1=$(grep "rlnAmplitudeContrast" $starin | awk '{print $2}' | sed 's/#//g')

echo ""
echo "Star file:               ${starin}"
echo "rlnMicrographName:       ${micnamecol1}"
echo "rlnDefocusU:             ${defUcol1}"
echo "rlnDefocusV:             ${defVcol1}"
echo "rlnDefocusA:             ${defAcol1}"
echo "rlnDetectorPixelSize:    ${dstepcol1}"
echo "rlnMagnification:        ${magcol1}"
echo "rlnVoltage:              ${kvcol1}"
echo "rlnSphericalAberration:  ${cscol1}"
echo "rlnAmplitudeContrast:    ${ampcol1}"
echo ""

## Create new directory for creating simple file in
mkdir -p ${simpledir}/${outdir}
echo "Created directory for simple file output..."
echo "${simpledir}/${outdir}"

## Get defocusU/V and astig columns without the header of the star file and place in simple formatted ctf params file
# Note that as of Relion-3.0 version header needs removing
cat $starin | grep -v "# RELION" | awk \
-v c1="$kvcol1" -v c2="$cscol1" -v c3="$ampcol1" \
-v c4="$defUcol1" -v c5="$defVcol1" -v c6="$defAcol1" \
'BEGIN {i=1} {if (NF<3) {i++} else {print "kv="$c1,"cs="$c2,"fraca="$c3,"dfx="$c4/10000,"dfy="$c5/10000,"angast="$11}}' > deftab.txt
ptclno=$(wc -l deftab.txt | awk '{print $1}')

mv deftab.txt ${simpledir}/${outdir}
echo "Created Simple formatted deftab.txt in output directory"
echo ""

## Get microscope and data set parameters
kv1=$(cat $starin | grep -v "# RELION" | awk -v c1="$kvcol1" 'BEGIN {i=1} {if (NF<3) {i++} else {print $c1}}' | head -n 1)
cs1=$(cat $starin | grep -v "# RELION" | awk -v c1="$cscol1" 'BEGIN {i=1} {if (NF<3) {i++} else {print $c1}}' | head -n 1)
amp1=$(cat $starin | grep -v "# RELION" | awk -v c1="$ampcol1" 'BEGIN {i=1} {if (NF<3) {i++} else {print $c1}}' | head -n 1)
dstep=$(cat $starin | grep -v "# RELION" | awk -v c1="$dstepcol1" 'BEGIN {i=1} {if (NF<3) {i++} else {print $c1}}' | head -n 1)
mag=$(cat $starin | grep -v "# RELION" | awk -v c1="$magcol1" 'BEGIN {i=1} {if (NF<3) {i++} else {print $c1}}' | head -n 1)
ptclno=$(wc -l ${simpledir}/${outdir}/deftab.txt | awk {'print $1'})

# Calculate pixel size
apix=$(bc <<< "scale=3; ${dstep}*10000/${mag}")

## Report useful values
echo "Voltage: ${kv1}"
echo "Cs (mm): ${cs1}"
echo "AmpC:    ${amp1}"
echo "Apix:    ${apix}"
echo "Ptcl no: ${ptclno}"
echo ""

## Save a useful file to pull info from
echo "Simple parameters" > ${simpledir}/${outdir}/.params.dat
echo "Voltage: ${kv1}" >> ${simpledir}/${outdir}/.params.dat
echo "Cs (mm): ${cs1}" >> ${simpledir}/${outdir}/.params.dat
echo "AmpC:    ${amp1}" >> ${simpledir}/${outdir}/.params.dat
echo "Apix:    ${apix}" >> ${simpledir}/${outdir}/.params.dat
echo "Ptcl no: ${ptclno}" >> ${simpledir}/${outdir}/.params.dat

## Use relion to create a single stack of the particles
echo "Using Relion to create a single stack with and without phase flipping..."
echo ""
relion_preprocess --operate_on ${starin} --reextract_data_star --operate_out ${simpledir}/${outdir}/particles_pflip --premultiply_ctf --phase_flip
echo "Created phase flipped particles..."
echo ""
relion_preprocess --operate_on ${starin} --reextract_data_star --operate_out ${simpledir}/${outdir}/particles
echo "Created normal particles..."
echo ""
#relion_stack_create --i ${starin} --o simple/${name}

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
