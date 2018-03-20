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


star1=$1
star2=$2

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_star_join (1) (2)"
  echo ""
  echo "(1) = star1"
  echo "(2) = star2"
  echo ""
  exit

fi

rm -rf *.dat

#Get header of star1
awk '{if (NF > 3) exit; print }' < ${star1} > star1header.dat
awk '{print $1,$2}' star1header.dat | sed '1,4d' > tmp.dat
mv tmp.dat star1header_trim.dat
awk '{print $1}' star1header_trim.dat > star1header_trimcol.dat
diff star1header.dat ${star1} | awk '!($1="")' > star1lines.dat
sed '1d' star1lines.dat > tmp.dat
mv tmp.dat star1lines.dat

#Get header of star2
awk '{if (NF > 3) exit; print }' < ${star2} > star2header.dat
awk '{print $1,$2}' star2header.dat | sed '1,4d' > tmp.dat
mv tmp.dat star2header_trim.dat
awk '{print $1}' star2header_trim.dat > star2header_trimcol.dat
diff star2header.dat ${star2} | awk '!($1="")' > star2lines.dat
sed '1d' star2lines.dat > tmp.dat
mv tmp.dat star2lines.dat

#Build re-ordered column star files ready for adding together

#For star number 1
echo '' > star1lines_col.dat
echo ''
echo 'Star file 1 column order as follows:'
while read p; do
  column=$(grep $p star1header_trim.dat | awk '{print $2}' | sed 's/#//g')
  echo $p "#"$column
  awk '{print $col}' col=$column star1lines.dat > tmp.dat
  paste -d' ' star1lines_col.dat tmp.dat > tmp2.dat
  mv tmp2.dat star1lines_col.dat
done < star1header_trimcol.dat
echo ''

#For star number 2
echo '' > star2lines_col.dat
echo 'Star file 2 column order reordered as follows:'
while read p; do
  column=$(grep $p star2header_trim.dat | awk '{print $2}' | sed 's/#//g')
  echo $p "#"$column
  awk '{print $col}' col=$column star2lines.dat > tmp.dat
  paste -d' ' star2lines_col.dat tmp.dat > tmp2.dat
  mv tmp2.dat star2lines_col.dat
done < star1header_trimcol.dat
echo ''

### OLD CODE FOR MANUALLY AWK'ING STAR FILES ###
#awk columns in correct order to tmp files
#awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' star1lines.dat > star1lines_awk.dat
#awk '{print $11,$8,$2,$3,$4,$1,$5,$10,$9,$6,$7}' star2lines.dat > star2lines_awk.dat
################################################

echo 'Adding star files to one another...'
echo ''
#Add reordered star files together removing any empty rows
cat star1lines_col.dat star2lines_col.dat > star_combined.dat
grep '[^[:blank:]]' < star_combined.dat > tmp.dat
mv tmp.dat star_combined.dat
echo 'Combined star file contains' $(wc -l star_combined.dat | awk '{print $1}') 'lines'
echo ''
echo 'Adding header from star file 1 to star_combined...'
echo 'Header has' $(wc -l star1header.dat) 'lines'
echo ''
#Add header to combined reordered star_file
cat star1header.dat star_combined.dat > star_combined.star

echo 'Combined star file data saved in star_combined.star'
echo 'Done!'
echo ''

rm -rf *.dat
