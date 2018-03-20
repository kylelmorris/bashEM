#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of Warwick 2016
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

##
# Replace ctf estimation information in star file from new reference star file
##

starin=$1
starsource=$2

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_star_replace_data.sh (1) (2)"
  echo ""
  echo "(1) = star to replace data in"
  echo "(2) = star to source new data from"
  echo ""
  exit

fi

rm -rf *.dat

echo 'If ready press any key to continue, ctrl-c to quit'
read p

#Get header and data lines of star1
awk '{if (NF > 3) exit; print }' < ${starin} > star1header.dat
awk '{print $1,$2}' star1header.dat | sed '1,4d' > tmp.dat
mv tmp.dat star1header_trim.dat
awk '{print $1}' star1header_trim.dat > star1header_trimcol.dat
diff star1header.dat ${starin} | awk '!($1="")' > star1lines.dat
sed '1d' star1lines.dat > tmp.dat
mv tmp.dat star1lines.dat

#Get header and data lines of star2
awk '{if (NF > 3) exit; print }' < ${starsource} > star2header.dat
awk '{print $1,$2}' star2header.dat | sed '1,4d' > tmp.dat
mv tmp.dat star2header_trim.dat
awk '{print $1}' star2header_trim.dat > star2header_trimcol.dat
diff star2header.dat ${starsource} | awk '!($1="")' > star2lines.dat
sed '1d' star2lines.dat > tmp.dat
mv tmp.dat star2lines.dat

#Get column numbers
star1_col_OriginX=$(grep "OriginX" star1header_trim.dat | awk '{print $2}' | sed 's/#//g')
star1_col_OriginY=$(grep "OriginY" star1header_trim.dat | awk '{print $2}' | sed 's/#//g')
star1_col_AngleRot=$(grep "AngleRot" star1header_trim.dat | awk '{print $2}' | sed 's/#//g')
star1_col_AngleTilt=$(grep "AngleTilt" star1header_trim.dat | awk '{print $2}' | sed 's/#//g')
star1_col_AnglePsi=$(grep "AnglePsi" star1header_trim.dat | awk '{print $2}' | sed 's/#//g')

star2_col_OriginX=$(grep "OriginX" star2header_trim.dat | awk '{print $2}' | sed 's/#//g')
star2_col_OriginY=$(grep "OriginY" star2header_trim.dat | awk '{print $2}' | sed 's/#//g')
star2_col_AngleRot=$(grep "AngleRot" star2header_trim.dat | awk '{print $2}' | sed 's/#//g')
star2_col_AngleTilt=$(grep "AngleTilt" star2header_trim.dat | awk '{print $2}' | sed 's/#//g')
star2_col_AnglePsi=$(grep "AnglePsi" star2header_trim.dat | awk '{print $2}' | sed 's/#//g')

#Report column numbers
echo "Found columns OriginX:   " $star1_col_OriginX $star2_col_OriginX
echo "Found columns OriginY:   " $star1_col_OriginY $star2_col_OriginY
echo "Found columns AngleRot:  " $star1_col_AngleRot $star2_col_AngleRot
echo "Found columns AngleTilt: " $star1_col_AngleTilt $star2_col_AngleTilt
echo "Found columns AnglePsi:  " $star1_col_AnglePsi $star2_col_AnglePsi

while read p; do
  echo $p
done < star1lines.dat

rm -rf *.dat
exit 1

## THIS SCRIPT IS NOT FINISHED ##
