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


if [[ -z $1 ]] || [[ -z $2 ]] ; then
  echo ""
  echo "Variables empty, usage is relion_star_to_simple_ctf (1) (2)"
  echo ""
  echo "(1) = star file"
  echo "(2) = out file basename (no extension)"
  echo ""
  exit
fi

## Input star file
starin=$1
out=$2
name=$(basename $starin .star)
echo ""
echo 'Working on star file:'  $name.star
echo 'Working on mrcs stack:' $name.mrcs
echo ""

## Get the defocusU/V and astig column numbers
c1=$(grep rlnDefocusU $starin | awk '{print $2}' | sed 's/#//g')
c2=$(grep rlnDefocusV $starin | awk '{print $2}' | sed 's/#//g')
c3=$(grep rlnDefocusAngle $starin | awk '{print $2}' | sed 's/#//g')

## Get defocusU/V and astig columns without the header of the star file and place in simple formatted ctf params file
awk -v c1="$c1" -v c2="$c2" -v c3="$c3" 'BEGIN {i=1} {if (NF<3) {i++} else {print "dfx="$c1/10000,"dfy="$c2/10000,"angast="$11}}' $starin > ctfparams.txt
ptclno=$(wc -l ctfparams.txt | awk '{print $1}')
echo ""
echo "Created Simple formatted ctfparams.txt"

## Create a new star file which has only the defocus, astig and pixel size params in reference to ctf corrected stack
### Create data columns for single stack of particles with same name as input star file
relion_star_datablock_stack $ptclno $out"_phflip.mrcs" > datablock_ImageName
### Get data columns from star file
relion_star_printtable $starin data rlnDefocusU rlnDefocusV rlnDefocusAngle rlnDetectorPixelSize rlnMagnification rlnAmplitudeContrast rlnVoltage rlnSphericalAberration > datablock_data
### Create new header for data columns
relion_star_loopheader rlnImageName rlnDefocusU rlnDefocusV rlnDefocusAngle rlnDetectorPixelSize rlnMagnification rlnAmplitudeContrast rlnVoltage rlnSphericalAberration > header
### Combine data together into new star file
paste datablock_ImageName datablock_data | awk {'print $1,$2,$3,$4,$5,$6,$7,$8,$9'} > datablock
cat header datablock > $out"_phflip.star"
echo ""
echo "Created Relion formatted ctfparams.star referring to input stack:" $name.mrcs

rm -rf datablock
rm -rf datablock_ImageName
rm -rf datablock_data
rm -rf header

echo ""
echo "Done!"
echo ""
echo "Don't forget to phaseflip the stack using simple_stackops"
echo "simple_stackops stk="$name".mrcs smpd=2.18 deftab=ctfparams.txt ctf=flip kv=120 cs=6.3 fraca=0.15 outstk="$out"_phflip.mrcs"
echo ""
