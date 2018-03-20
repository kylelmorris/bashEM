#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of California Berkeley 2016
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

rm -rf *.dat

#Loops through using filelist.dat
ls *.star > filelist.dat
fileno=$(wc -l filelist.dat | awk {'print $1'})
echo ""
echo "Printing star files in the current working directory..."
echo ""
ls -han *.star | awk {'print $9'} | cat -n
echo ""
echo "The ${fileno} star files in this directory will be joined..."
echo ""
read -p "Press [Enter] key to confirm and run script..."
echo ""

#Put line 1 into tmp file
star1=$(sed -n "1p" filelist.dat)
scp -r $star1 tmp.star
echo "+++ Working on:" $star1

i=1
while [ $i -lt $fileno ] ; do
   #Get header of tmp file
   awk '{if (NF > 3) exit; print }' < tmp.star > star1header.dat
   awk '{print $1,$2}' star1header.dat | sed '1,4d' > tmp.dat
   mv tmp.dat star1header_trim.dat
   awk '{print $1}' star1header_trim.dat > star1header_trimcol.dat
   diff star1header.dat tmp.star | awk '!($1="")' > star1lines.dat
   sed '1d' star1lines.dat > tmp.dat
   mv tmp.dat star1lines.dat

   #Get header of $i+1 file in filelist
   j=$(echo "${i}p")
   star2=$(sed -n $j filelist.dat)
   echo "+++ Working on:" $star2
   progress=$(($fileno-$i))
   echo "${progress} star files remaining to join..."
   echo ""
   #Get header of star2
   awk '{if (NF > 3) exit; print }' < ${star2} > star2header.dat
   awk '{print $1,$2}' star2header.dat | sed '1,4d' > tmp.dat
   mv tmp.dat star2header_trim.dat
   awk '{print $1}' star2header_trim.dat > star2header_trimcol.dat
   diff star2header.dat ${star2} | awk '!($1="")' > star2lines.dat
   sed '1d' star2lines.dat > tmp.dat
   mv tmp.dat star2lines.dat

   #Combine $i+1 with tmp file
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
   echo 'Adding star files to one another...'
   echo ''
   #Add reordered star files together removing any empty rows
   cat star1lines_col.dat star2lines_col.dat > star_combined.dat
   grep '[^[:blank:]]' < star_combined.dat > tmp.dat
   mv tmp.dat star_combined.dat
   echo 'Combined star file now contains' $(wc -l star_combined.dat | awk '{print $1}') 'lines'
   echo ''
   echo 'Adding header from star file 1 to star_combined...'
   echo 'Header has' $(wc -l star1header.dat) 'lines'
   echo ''
   #Add header to combined reordered star_file
   #Move combined file into tmp file
   cat star1header.dat star_combined.dat > tmp.star

   i=$((i+1))
done

#Move tmp into final star file
mv tmp.star star_combined.star

echo 'Combined star file data saved in star_combined.star'
echo 'Done!'
echo ''

rm -rf *.dat
