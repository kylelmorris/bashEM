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

xshift=$2
yshift=$3

rotshift=$4
tiltshift=$5
psishift=$6

tilthshift=$7
psihshift=$8

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] || [[ -z $5 ]] || [[ -z $6 ]]  || [[ -z $7 ]] || [[ -z $8 ]]; then

  echo ""
  echo "Variables empty, usage is relion_star_shift_particles.sh (1) (2) (3) (4) (5) (6) (7) (8) "
  echo ""
  echo "(1) = Particle star file in"
  echo "(2) = x shift (px)"
  echo "(3) = y shift (px)"
  echo "(4) = rot shift (deg)"
  echo "(5) = tilt shift (deg)"
  echo "(6) = psi shift (deg)"
  echo "(7) = helical tilt shift (deg)"
  echo "(8) = helical psi shift (deg)"
  exit

fi

# Star output will be
starbase=$(basename $starin .star)
starout=${starbase}_shifted.star

# Make sure directory is clean
rm -rf *.dat
rm -rf $starout

###############################################################################
# Get column number and data for rlnImageName from starin
###############################################################################
echo ""
imgnamecol1=$(grep "rlnImageName " $starin | awk '{print $2}' | sed 's/#//g')
# Get angular columns from starin
rotcol1=$(grep "rlnAngleRot " $starin | awk '{print $2}' | sed 's/#//g')
tiltcol1=$(grep "rlnAngleTilt " $starin | awk '{print $2}' | sed 's/#//g')
psicol1=$(grep "rlnAnglePsi " $starin | awk '{print $2}' | sed 's/#//g')
# Get xy translations from starreplace
orixcol1=$(grep "rlnOriginX " $starin | awk '{print $2}' | sed 's/#//g')
oriycol1=$(grep "rlnOriginY " $starin | awk '{print $2}' | sed 's/#//g')
# Helical parameters
tilthcol1=$(grep "rlnAngleTiltPrior " $starin | awk '{print $2}' | sed 's/#//g')
psihcol1=$(grep "rlnAnglePsiPrior " $starin | awk '{print $2}' | sed 's/#//g')

echo "${starin} particle file columns:"
echo "rlnImageName:     # $imgnamecol1"
echo "rlnOriginX:       # $orixcol1"
echo "rlnOriginY:       # $oriycol1"
echo "rlnAngleRot:      # $rotcol1"
echo "rlnAngleTilt:     # $tiltcol1"
echo "rlnAnglePsi:      # $psicol1"
echo "rlnAngleTiltPrior:# $tilthcol1"
echo "rlnAnglePsiPrior: # $psihcol1"
echo ""

echo "rlnOriginX shift:   $xshift"
echo "rlnOriginY shift:   $yshift"
echo "rlnAngleRot shift:  $rotshift"
echo "rlnAngleTilt shift: $tiltshift"
echo "rlnAnglePsi shift:  $psishift"
echo "rlnAngleTiltPrior:# $tilthshift"
echo "rlnAnglePsiPrior: # $psihshift"
echo ""

echo "Hit enter if happy with above... or ctrl-c to quit"
read p

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
# Loop through starin data line by line and look up new defocus values newdefocus.dat
###############################################################################
echo ""
i=1
while read dataline
do

  #Get data line current angular values
  currentxy=$(echo $dataline | awk -v mic=$imgnamecol1 \
  -v X=$orixcol1 -v Y=$oriycol1 \
  -v R=$rotcol1 -v T=$tiltcol1 -v P=$psicol1 \
  -v Rh=$tilthcol1 -v Ph=$psihcol1 '{print $X,$Y}')

  currentdeg=$(echo $dataline | awk -v mic=$imgnamecol1 \
  -v X=$orixcol1 -v Y=$oriycol1 \
  -v R=$rotcol1 -v T=$tiltcol1 -v P=$psicol1 \
  -v Rh=$tilthcol1 -v Ph=$psihcol1 '{print $R,$T,$P}')

  currentdegh=$(echo $dataline | awk -v mic=$imgnamecol1 \
  -v X=$orixcol1 -v Y=$oriycol1 \
  -v R=$rotcol1 -v T=$tiltcol1 -v P=$psicol1 \
  -v Rh=$tilthcol1 -v Ph=$psihcol1 '{print $Rh,$Ph}')

  #Get data line image name from particle star data lines without path and without extension
  tmp=$(echo $dataline | awk '{print $imgname}' imgname=$imgnamecol1 | grep -oE "[^/]+$")
  imgname=${tmp%.*}
  tmp=$(echo $dataline | awk '{print $imgname}' imgname=$imgnamecol1)
  imgno=$(echo $tmp | sed 's/@.*//')

  #Report updated useful information
  #echo -en "\e[9A"
  echo "Working on line: ${i} of ${lineno}"
  #echo "Data line:"
  #echo $dataline
  echo "Current rlnImageName:             ${imgname}"
  echo "Current stack number:             ${imgno}"
  echo "Current XY values:                ${currentxy}"
  echo "Current angular values:           ${currentdeg}"
  echo "Current angular values (helical): ${currentdegh}"
  echo ""

  #Find the current image and according data in the starreplace data
  replace=$(grep $imgname star1lines.dat | grep $imgno |  \
  awk -v mic=$imgnamecol1 \
  -v X=$orixcol1 -v Y=$oriycol1 \
  -v R=$rotcol1 -v T=$tiltcol1 -v P=$psicol1 \
  -v Th=$tilthcol1 -v Ph=$psihcol1 \
  -v x=$xshift -v y=$yshift \
  -v r=$rotshift -v t=$tiltshift -v p=$psishift \
  -v th=$tilthshift -v ph=$psihshift \
  '{print $X-x,$Y-y,$R-r,$T-t,$P-p,$Th-th,$Ph-ph}')

  #Store these values in Variables
  neworix=$(echo $replace | awk '{print $1}')
  neworiy=$(echo $replace | awk '{print $2}')
  newrot=$(echo $replace | awk '{print $3}')
  newtilt=$(echo $replace | awk '{print $4}')
  newpsi=$(echo $replace | awk '{print $5}')
  newtilth=$(echo $replace | awk '{print $6}')
  newpsih=$(echo $replace | awk '{print $7}')

  #Report these values as sanity check
  echo "Replace XY values:                ${neworix} ${neworiy}"
  echo "Replace angular values:           ${newrot} ${newtilt} ${newpsi}"
  echo "Replace angular values (helical): ${newtilth} ${newpsih}"
  echo ""

  #Create new star file line but replace the UVA defocus information
  #echo "New data line:"
  newline=$(echo $dataline | \
  awk '{$R=newrot;$T=newtilt;$P=newpsi;$Th=newtilth;$Ph=newpsih;$X=neworix;$Y=neworiy;print}' \
  R=$rotcol1 T=$tiltcol1 P=$psicol1 \
  X=$orixcol1 Y=$oriycol1 \
  Th=$tilthcol1 Ph=$psihcol1 \
  newrot=$newrot newtilt=$newtilt newpsi=$newpsi \
  newtilth=$newtilth newpsih=$newpsih \
  neworix=$neworix neworiy=$neworiy)

  #echo $newline
  echo $newline >> datalinesnew.dat

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
cat star1header.dat datalinesnew.dat > $starout

# Tidy up
rm -rf *dat

# Useful message
echo "Saved new xyang replaced star file to: ${starout}"
echo ""
echo "Done!"
echo ""
