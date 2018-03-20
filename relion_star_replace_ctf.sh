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
starctf=$2

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_star_replace_ctf.sh (1) (2)"
  echo ""
  echo "(1) = star in"
  echo "(2) = New ctf estimation list (in star format)"
  echo ""
  exit

fi

rm -rf *.dat

#Get header of star1
awk '{if (NF > 3) exit; print }' < ${starin} > star1header.dat
awk '{print $1,$2}' star1header.dat | sed '1,4d' > tmp.dat
mv tmp.dat star1header_trim.dat
awk '{print $1}' star1header_trim.dat > star1header_trimcol.dat
diff star1header.dat ${starin} | awk '!($1="")' > star1lines.dat
sed '1d' star1lines.dat > tmp.dat
mv tmp.dat star1lines.dat

#Get header of star2
awk '{if (NF > 3) exit; print }' < ${starctf} > star2header.dat
awk '{print $1,$2}' star2header.dat | sed '1,4d' > tmp.dat
mv tmp.dat star2header_trim.dat
awk '{print $1}' star2header_trim.dat > star2header_trimcol.dat
diff star2header.dat ${starctf} | awk '!($1="")' > star2lines.dat
sed '1d' star2lines.dat > tmp.dat
mv tmp.dat star2lines.dat

col_mic=$(grep "Micrograph" star1header_trim.dat | awk '{print $2}' | sed 's/#//g')
col_DFU=$(grep "DefocusU" star1header_trim.dat | awk '{print $2}' | sed 's/#//g')
col_DFV=$(grep "DefocusV" star1header_trim.dat | awk '{print $2}' | sed 's/#//g')
col_DFang=$(grep "DefocusAngle" star1header_trim.dat | awk '{print $2}' | sed 's/#//g')

col_ctfmic=$(grep "Micrograph" star2header_trim.dat | awk '{print $2}' | sed 's/#//g')
col_ctfDFU=$(grep "DefocusU" star2header_trim.dat | awk '{print $2}' | sed 's/#//g')
col_ctfDFV=$(grep "DefocusV" star2header_trim.dat | awk '{print $2}' | sed 's/#//g')
col_ctfDFang=$(grep "DefocusAngle" star2header_trim.dat | awk '{print $2}' | sed 's/#//g')

#echo $col_mic
#echo $col_ctfmic
#echo ''
#echo $col_DFU
#echo $col_ctfDFU
#echo ''
#echo $col_DFV
#echo $col_ctfDFV
#echo ''
#echo $col_DFang
#echo $col_ctfDFang

echo '' > new_lines.dat

while read p; do
  currentmic=$(echo $p | awk '{print $col}' col=$col_mic | sed 's/micrographs\///g' | sed 's/_SumCorr_1-17.mrc//g')
  echo 'Working on:' $(echo $p | awk '{print $col}' col=$col_mic | sed 's/micrographs\///g' | sed 's/_SumCorr_1-17.mrc//g')
  #echo 'DFU:' $(echo $p | awk '{print $col}' col=$col_DFU)
  DFU=$(echo $p | awk '{print $col}' col=$col_DFU)
  #echo 'DFV:' $(echo $p | awk '{print $col}' col=$col_DFV)
  DFV=$(echo $p | awk '{print $col}' col=$col_DFV)
  #echo 'DFang:' $(echo $p | awk '{print $col}' col=$col_DFang)
  DFang=$(echo $p | awk '{print $col}' col=$col_DFang)
  #echo ''

  DFUnew=$(grep $currentmic star2lines.dat | awk '{print $col}' col=$col_ctfDFU)
  if [ -z $DFUnew ]; then
  #echo 'DFU empty:' $DFU
  DFUnew=$DFU
  #else
  #echo 'New DFU:' $(grep $currentmic star2lines.dat | awk '{print $col}' col=$col_ctfDFU)
  fi

  DFVnew=$(grep $currentmic star2lines.dat | awk '{print $col}' col=$col_ctfDFV)
  if [ -z $DFVnew ]; then
  #echo 'DFV empty:' $DFV
  DFVnew=$DFV
  #else
  #echo 'New DFV:' $(grep $currentmic star2lines.dat | awk '{print $col}' col=$col_ctfDFV)
  fi

  DFangnew=$(grep $currentmic star2lines.dat | awk '{print $col}' col=$col_ctfDFang)
  if [ -z $DFangnew ]; then
  #echo 'DFang empty:' $DFang
  DFangnew=$DFang
  #else
  #echo 'New DFang:' $(grep $currentmic star2lines.dat | awk '{print $col}' col=$col_ctfDFang)
  fi

  #echo ''
  #echo 'Old line:' $p
  #echo 'New line:' $(echo $p | awk '{$DFUcol=DFUnew;$DFVcol=DFVnew;$DFangcol=DFangnew;print}' DFUcol=$col_DFU DFUnew=$DFUnew DFVcol=$col_DFV DFVnew=$DFVnew DFangcol=$col_DFang DFangnew=$DFangnew)
  #echo ''

  echo $p | awk '{$DFUcol=DFUnew;$DFVcol=DFVnew;$DFangcol=DFangnew;print}' DFUcol=$col_DFU DFUnew=$DFUnew DFVcol=$col_DFV DFVnew=$DFVnew DFangcol=$col_DFang DFangnew=$DFangnew > new_line.dat
  cat new_lines.dat new_line.dat > tmp.dat
  mv tmp.dat new_lines.dat

done < star1lines.dat
echo ''

cat star1header.dat new_lines.dat >> new_star_ctf.star

rm -rf *.dat
