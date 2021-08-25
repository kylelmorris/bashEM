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
  echo "Variables empty, usage is relion_star_replace_UVA_ptcl_from_mics.sh (1) (2)"
  echo ""
  echo "(1) = Particle star file in"
  echo "(2) = Particle star file containing replace UVA information"
  exit

fi

# Make sure directory is clean
rm -rf *.dat
rm -rf star_replaced_UVA.star

###############################################################################
# Get column number and data for rlnImageName from starin
###############################################################################
imgnamecol2=$(grep "rlnImageName" $starin | awk '{print $2}' | sed 's/#//g')
# Get columns rlnDefocusU, rlnDefocusV, rlnDefocusAngle from starin
defUcol2=$(grep "rlnDefocusU" $starin | awk '{print $2}' | sed 's/#//g')
defVcol2=$(grep "rlnDefocusV" $starin | awk '{print $2}' | sed 's/#//g')
defAcol2=$(grep "rlnDefocusAngle" $starin | awk '{print $2}' | sed 's/#//g')
# Get pixel size and mag from starreplace
dstepcol2=$(grep "rlnDetectorPixelSize" $starin | awk '{print $2}' | sed 's/#//g')
magcol2=$(grep "rlnMagnification" $starin | awk '{print $2}' | sed 's/#//g')

echo "${starin} particle file columns:"
echo "rlnImageName: $imgnamecol2"
echo "rlnDefocusU: $defUcol2"
echo "rlnDefocusV: $defVcol2"
echo "rlnDefocusA: $defAcol2"
echo "rlnDetectorPixelSize: $dstepcol2"
echo "rlnMagnification:      $magcol2"
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
micnamecol1=$(grep "rlnMicrographName" $starreplace | awk '{print $2}' | sed 's/#//g')
# Get columns rlnDefocusU, rlnDefocusV, rlnDefocusAngle from starreplace
defUcol1=$(grep "rlnDefocusU" $starreplace | awk '{print $2}' | sed 's/#//g')
defVcol1=$(grep "rlnDefocusV" $starreplace | awk '{print $2}' | sed 's/#//g')
defAcol1=$(grep "rlnDefocusAngle" $starreplace | awk '{print $2}' | sed 's/#//g')
# Get pixel size and mag from starreplace
dstepcol1=$(grep "rlnDetectorPixelSize" $starreplace | awk '{print $2}' | sed 's/#//g')
magcol1=$(grep "rlnMagnification" $starreplace | awk '{print $2}' | sed 's/#//g')

echo "$starreplace file columns:"
echo "rlnMicrographName: $micnamecol1"
echo "rlnDefocusU: $defUcol1"
echo "rlnDefocusV: $defVcol1"
echo "rlnDefocusA: $defAcol1"
echo "rlnDetectorPixelSize: $dstepcol1"
echo "rlnMagnification:      $magcol1"
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

  #Get data line current defocusU, defocusV and defocusA (UVA) values
  current=$(echo $dataline | awk -v mic=$imgnamecol2 -v U=$defUcol2 -v V=$defVcol2 -v A=$defAcol2 '{print $U,$V,$A}')

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
  echo "Current rlnImageName: "$imgname
  echo "Current stack number: "$imgno
  echo "Current UVA values:   "$current
  echo ""

  #Find the current image and according data in the starreplace data
  replace=$(grep $imgname star2lines.dat | grep $imgno |  awk -v mic=$micnamecol1 -v U=$defUcol1 -v V=$defVcol1 -v A=$defAcol1 -v D=$dstepcol1 -v M=$magcol1 '{print $U,$V,$A,$D,$M}')
  #Store these values in Variables
  newdefU=$(echo $replace | awk '{print $1}')
  newdefV=$(echo $replace | awk '{print $2}')
  newdefA=$(echo $replace | awk '{print $3}')
  newdstep=$(echo $replace | awk '{print $4}')
  newmag=$(echo $replace | awk '{print $5}')

  #Report these values as sanity check
  echo "Replace UVA values: ${newdefU} ${newdefV} ${newdefA}"
  echo "Replace mag values: ${newdstep} ${newmag}"
  echo ""

  #Create new star file line but replace the UVA defocus information
  #echo "New data line:"
  newline=$(echo $dataline | awk '{$U=newdefU;$V=newdefV;$A=newdefA;$D=newdstep;$M=newmag;print}' U=$defUcol2 V=$defVcol2 A=$defAcol2 D=$dstepcol2 M=$magcol2 newdefU=$newdefU newdefV=$newdefV newdefA=$newdefA newdstep=$newdstep newmag=$newmag)
  #echo $newline
  echo $newline >> datalinesnew.dat

  #echo ""

  echo -en "\e[8A"
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
echo "Number of data lines in new UVA replaced particle star file:"
echo $(wc -l datalinesnew.dat | awk '{print $1}')
echo ""

# Send header to new star file, followed by each new line with replaced UVA
cat star1header.dat datalinesnew.dat > star_replaced_UVA.star

# Tidy up
rm -rf *dat

# Useful message
echo "Saved new UVA replaced star file to: star_replaced_UVA.star"
echo ""
echo "Done!"
echo ""
