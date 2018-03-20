#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of California Berkeley 2017
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

# Variables
starin=$1
starreplace=$2

if [[ -z $1 ]] || [[ -z $2 ]]; then

  echo ""
  echo "Variables empty, usage is relion_star_replace_xyang_ptcl_from_mics.sh (1) (2)"
  echo ""
  echo "(1) = Particle star file in"
  echo "(2) = Particle star file containing replace xy + angular information"
  exit

fi

# Make sure directory is clean
rm -rf *.dat
rm -rf star_replaced_xyang.star

###############################################################################
# Get column number and data for rlnImageName from starin
###############################################################################
imgnamecol2=$(grep "rlnImageName" $starin | awk '{print $2}' | sed 's/#//g')
# Get angular columns from starin
rotcol2=$(grep "rlnAngleRot" $starin | awk '{print $2}' | sed 's/#//g')
tiltcol2=$(grep "rlnAngleTilt" $starin | awk '{print $2}' | sed 's/#//g')
psicol2=$(grep "rlnAnglePsi" $starin | awk '{print $2}' | sed 's/#//g')
# Get xy translations from starreplace
orixcol2=$(grep "rlnOriginX" $starin | awk '{print $2}' | sed 's/#//g')
oriycol2=$(grep "rlnOriginY" $starin | awk '{print $2}' | sed 's/#//g')

echo "${starin} particle file columns:"
echo "rlnImageName: $imgnamecol2"
echo "rlnAngleRot:  $rotcol2"
echo "rlnAngleTilt: $tiltcol2"
echo "rlnAnglePsi:  $psicol2"
echo "rlnOriginX:   $orixcol2"
echo "rlnOriginY:   $oriycol2"
echo ""

###############################################################################
# Split starin into header and data lines
###############################################################################
awk '{if (NF > 3) exit; print }' < ${starin} > star1header.dat
awk '{print $1,$2}' star1header.dat | sed '1,4d' > tmp.dat
mv tmp.dat star1header_trim.dat
awk '{print $1}' star1header_trim.dat > star1header_trimcol.dat
diff star1header.dat ${starin} | awk '!($1="")' > star1lines.dat
sed '1d' star1lines.dat > tmp.dat
mv tmp.dat star1lines.dat

# Get number of data lines in particle star file to work on
lineno=$(wc -l star1lines.dat | awk '{print $1}')

###############################################################################
# Get column number and data for rlnMicrographName from starreplace
###############################################################################
imgnamecol1=$(grep "rlnMicrographName" $starreplace | awk '{print $2}' | sed 's/#//g')
# Get angular columns from starreplace
rotcol1=$(grep "rlnAngleRot" $starreplace | awk '{print $2}' | sed 's/#//g')
tiltcol1=$(grep "rlnAngleTilt" $starreplace | awk '{print $2}' | sed 's/#//g')
psicol1=$(grep "rlnAnglePsi" $starreplace | awk '{print $2}' | sed 's/#//g')
# Get xy translations from starreplace
orixcol1=$(grep "rlnOriginX" $starreplace | awk '{print $2}' | sed 's/#//g')
oriycol1=$(grep "rlnOriginY" $starreplace | awk '{print $2}' | sed 's/#//g')

echo "$starreplace file columns:"
echo "rlnImageName: $imgnamecol1"
echo "rlnAngleRot:  $rotcol1"
echo "rlnAngleTilt: $tiltcol1"
echo "rlnAnglePsi:  $psicol1"
echo "rlnOriginX:   $orixcol1"
echo "rlnOriginY:   $oriycol1"
echo ""

###############################################################################
# Split starreplace into header and data lines
###############################################################################
awk '{if (NF > 3) exit; print }' < $starreplace > star2header.dat
awk '{print $1,$2}' star2header.dat | sed '1,4d' > tmp.dat
mv tmp.dat star2header_trim.dat
awk '{print $1}' star2header_trim.dat > star2header_trimcol.dat
diff star2header.dat $starreplace | awk '!($1="")' > star2lines.dat
sed '1d' star2lines.dat > tmp.dat
mv tmp.dat star2lines.dat

###############################################################################
# Loop through starin data line by line and look up new defocus values newdefocus.dat
###############################################################################
echo ""
i=1
while read dataline
do

  #Get data line current angular values
  current=$(echo $dataline | awk -v mic=$imgnamecol2 -v R=$rotcol2 -v T=$tiltcol2 -v P=$psicol2 -v X=$orixcol2 -v Y=$oriycol2 '{print $R,$T,$P}')
  currentxy=$(echo $dataline | awk -v mic=$imgnamecol2 -v R=$rotcol2 -v T=$tiltcol2 -v P=$psicol2 -v X=$orixcol2 -v Y=$oriycol2 '{print $X,$Y}')

  #Get data line image name from particle star data lines without path and without extension
  tmp=$(echo $dataline | awk '{print $imgname}' imgname=$imgnamecol2 | grep -oE "[^/]+$")
  imgname=${tmp%.*}
  tmp=$(echo $dataline | awk '{print $imgname}' imgname=$imgnamecol2)
  imgno=$(echo $tmp | sed 's/@.*//')

  #Report updated useful information
  #echo -en "\e[9A"
  echo "Working on line: ${i} of ${lineno}"
  #echo "Data line:"
  #echo $dataline
  echo "Current rlnImageName:   ${imgname}"
  echo "Current stack number:   ${imgno}"
  echo "Current angular values: ${current}"
  echo "Current XY values:      ${currentxy}"
  echo ""

  #Find the current image and according data in the starreplace data
  replace=$(grep $imgname star2lines.dat | grep $imgno |  awk -v mic=$imgnamecol1 -v R=$rotcol1 -v T=$tiltcol1 -v P=$psicol1 -v X=$orixcol1 -v Y=$oriycol1 '{print $R,$T,$P,$X,$Y}')
  #Store these values in Variables
  newrot=$(echo $replace | awk '{print $1}')
  newtilt=$(echo $replace | awk '{print $2}')
  newpsi=$(echo $replace | awk '{print $3}')
  neworix=$(echo $replace | awk '{print $4}')
  neworiy=$(echo $replace | awk '{print $5}')

  #Report these values as sanity check
  echo "Replace angular values: ${newrot} ${newtilt} ${newpsi}"
  echo "Replace XY values:      ${neworix} ${neworiy}"
  echo ""

  #Create new star file line but replace the UVA defocus information
  #echo "New data line:"
  newline=$(echo $dataline | awk '{$U=newrot;$V=newtilt;$A=newpsi;$D=neworix;$M=neworiy;print}' U=$rotcol2 V=$tiltcol2 A=$psicol2 D=$orixcol2 M=$oriycol2 newrot=$newrot newtilt=$newtilt newpsi=$newpsi neworix=$neworix neworiy=$neworiy)
  #echo $newline
  echo $newline >> datalinesnew.dat

  #echo ""

  echo -en "\e[9A"
  #Useful information, math on percentage completeness
  #pcnt=$(bc <<< "scale=3; $i/$lineno*100")
  #echo -en "\e[1A"
  #echo "Completed ${pcnt}%"

  i=$((i+1))
done < star1lines.dat

# report sanity check stats
echo ""
echo "Number of data lines in original particle star file: "$starin
echo "${lineno}"
echo "Number of data lines in new xyang replaced particle star file:"
echo $(wc -l datalinesnew.dat | awk '{print $1}')
echo ""

# Send header to new star file, followed by each new line with replaced UVA
cat star1header.dat datalinesnew.dat > star_replaced_xyang.star

# Tidy up
rm -rf *dat

# Useful message
echo "Saved new xyang replaced star file to: star_replaced_xyang.star"
echo ""
echo "Done!"
echo ""
