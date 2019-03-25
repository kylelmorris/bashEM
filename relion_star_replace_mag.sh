#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of Berkeley 2017
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

starin=$1
mag=$2
dstep=$3

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]]; then

  echo ""
  echo "Variables empty, usage is relion_star_replace_mag.sh (1) (2) (3)"
  echo ""
  echo "(1) = Star to replace data in"
  echo "(2) = Magnification value for replace"
  echo "(3) = Physical pixel size (dstep) value for replace"
  echo ""
  exit

fi

echo ""
echo "Magnification and dstep should be in X and um and 6 d.p."
echo "Press Enter to confirm and continue"
read p

#Make sure directory is clean
rm -rf star1header.dat
rm -rf tmp.dat
rm -rf star1header_trimcol.dat
rm -rf star1lines.dat
rm -rf star1datalines.dat
rm -rf star1header_trim.dat

#Get header and data lines of star1
awk '{if (NF > 3) exit; print }' < ${starin} > star1header.dat
awk '{print $1,$2}' star1header.dat | sed '1,4d' > tmp.dat
mv tmp.dat star1header_trim.dat
awk '{print $1}' star1header_trim.dat > star1header_trimcol.dat
diff star1header.dat ${starin} | awk '!($1="")' > star1lines.dat
sed '1d' star1lines.dat > tmp.dat
sed '1d' star1lines.dat > tmp.dat
awk 'NF' tmp.dat > star1datalines.dat

#Get column numbers
star1_col_DetectorPixelSize=$(grep "rlnDetectorPixelSize" star1header_trim.dat | awk '{print $2}' | sed 's/#//g')
star1_col_Magnification=$(grep "rlnMagnification" star1header_trim.dat | awk '{print $2}' | sed 's/#//g')

#Report column numbers
echo "Found columns rlnDetectorPixelSize:   " $star1_col_DetectorPixelSize
echo "Found columns rlnMagnification    :   " $star1_col_Magnification

#Update values in star file
awk -v M=$star1_col_Magnification -v P=$star1_col_DetectorPixelSize \
-v newM=$mag -v newP=$dstep \
'{$M=newM;$P=newP; print}' star1datalines.dat > tmp.dat
cat star1header.dat tmp.dat > relion_star_replace_mag.star

#Make sure directory is clean
rm -rf star1header.dat
rm -rf tmp.dat
rm -rf star1header_trimcol.dat
rm -rf star1lines.dat
rm -rf star1datalines.dat
rm -rf star1header_trim.dat

#Useful information
echo ""
echo "Saved updated star file to:      ./relion_star_replace_mag.star"
echo "New magnification:               ${mag}"
echo "New pixel size:                  ${dstep}"
apix=$(bc <<< "scale=3; ${dstep}*10000/$mag")
echo "Calculated magnified pixel size: ${apix}"

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
