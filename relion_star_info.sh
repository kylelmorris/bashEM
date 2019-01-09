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

if [[ -z $1 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_star_info.sh (1)"
  echo ""
  echo "(1) = star1"
  echo ""
  exit

fi

rm -rf star1header.dat

#Get header of star1
awk 'NF < 3' < ${star1} > star1header.dat

#Get datalines of star1 and remove blank lines
diff star1header.dat ${star1} | awk '!($1="")' > star1lines.dat
sed '/^\s*$/d' star1lines.dat > tmp.dat
mv tmp.dat star1lines.dat

#Get single line of star1 for certain calculations
sed -n '1p' star1lines.dat > tmp.dat
mv tmp.dat star1line.dat

#Calculate number of particles by data lines minus header
totallines=$(wc -l $star1 | awk {'print $1'})
headerlines=$(wc -l star1header.dat | awk {'print $1'})
ptcllines=$(wc -l star1lines.dat | awk {'print $1'})

#Calculate pixel size
columnname=rlnDetectorPixelSize
column=$(grep ${columnname} ${star1} | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
temp=$(awk -v column=$column '{print $column}' star1line.dat)
dstep=$(bc <<< "scale=6; ${temp}/1")

columnname=rlnMagnification
column=$(grep ${columnname} ${star1} | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
temp=$(awk -v column=$column '{print $column}' star1line.dat)
#Convert scientific notation if present
temp1=`echo ${temp} | sed -e 's/[eE]+*/\\*10\\^/'`
mag=$(bc <<< "scale=0; ${temp1}/1")

#echo $value
apix=$(bc <<< "scale=3; ${dstep}*10000/${mag}")

#Get defocus column and calculate minimum and maximum defocus
columnname=rlnDefocusU
column=$(grep ${columnname} ${star1} | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
temp=$(awk -v column=$column '{print $column}' star1lines.dat | sort -n | head -n 1)
mindf=$(bc <<< "scale=0; ${temp}/10")
temp=$(awk -v column=$column '{print $column}' star1lines.dat | sort -n | tail -n 1)
maxdf=$(bc <<< "scale=0; ${temp}/10")

echo ''
echo '###############################################################'
echo 'File:' $star1
echo ''
echo 'Number of header lines in star file:           ' $headerlines
echo 'Number of data lines in star file:             ' $ptcllines
echo ''
echo 'Physical detector pixel size in star file (µm):' $dstep
echo 'Magnification in star file (X):                ' $mag
echo 'Calculated pixel size (apix):                  ' $apix
echo ''
echo 'Minimum defocus (nm):                          ' $mindf
echo 'Maximum defocus (nm):                          ' $maxdf
echo '##############################################################'
echo ''

rm -rf star1header.dat
rm -rf star1lines.dat
rm -rf star1line.dat
