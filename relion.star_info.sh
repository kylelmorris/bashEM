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
  echo "Variables empty, usage is: "
  echo ""
  echo "$(basename $0) (1)"
  echo ""
  echo "(1) = Input star file"
  echo ""
  exit

fi

# Test if star file is present
if [[ -e $star1 ]] ; then
  echo 'Star file found...'
  echo ''
else
  echo 'Star file not found, exiting...'
  echo ''
  exit
fi

# Tidy up from previous execution
rm -rf .star1header.dat

#Get header of star1
awk 'NF < 3' < ${star1} > .star1header.dat

#As of relion3 a version header is included in star file, ascertain for reporting and removal
search=$(grep "# RELION; version" ${star1})

if [[ -z ${search} ]] ; then
  version=$(echo "No Relion version header found...")
  diff .star1header.dat ${star1} | awk '!($1="")' > .star1lines.dat
else
  version=$(echo ${search})
  diff .star1header.dat ${star1} | sed "/${version}/d" | awk '!($1="")' > .star1lines.dat
fi

#Get datalines of star1 and remove blank lines
sed '/^\s*$/d' .star1lines.dat > .tmp.dat
mv .tmp.dat .star1lines.dat

#Get single line of star1 for certain calculations
sed -n '1p' .star1lines.dat > .tmp.dat
mv .tmp.dat .star1line.dat

#Calculate number of particles by data lines minus header
totallines=$(wc -l $star1 | awk {'print $1'})
headerlines=$(wc -l .star1header.dat | awk {'print $1'})
ptcllines=$(wc -l .star1lines.dat | awk {'print $1'})

#Calculate number of micrographs
columnname=rlnMicrographName
column=$(grep ${columnname} ${star1} | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
miclines=$(awk -v column=$column '{print $column}' .star1lines.dat | sort -u | wc -l | awk {'print $1'})

#Calculate number of image groups
columnname=rlnGroupNumber
column=$(grep ${columnname} ${star1} | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
grouplines=$(awk -v column=$column '{print $column}' .star1lines.dat | sort -u | wc -l | awk {'print $1'})

#Calculate number of classes
columnname=rlnClassNumber
column=$(grep ${columnname} ${star1} | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
classlines=$(awk -v column=$column '{print $column}' .star1lines.dat | sort -u | wc -l | awk {'print $1'})

#Calculate ptcls per micrograph in star file
ptclpermic=$(bc <<< "scale=0; ${ptcllines}/${miclines}")

#Calculate ptcls per class in star file
ptclperclass=$(bc <<< "scale=0; ${ptcllines}/${classlines}")

#Find cs (mm)
columnname=rlnSphericalAberration
column=$(grep ${columnname} ${star1} | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
temp=$(awk -v column=$column '{print $column}' .star1line.dat)
cs=${temp}

#Calculate pixel size
columnname=rlnDetectorPixelSize
column=$(grep ${columnname} ${star1} | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
temp=$(awk -v column=$column '{print $column}' .star1line.dat)
dstep=$(echo "scale=6; ${temp}/1" | bc)

columnname=rlnMagnification
column=$(grep ${columnname} ${star1} | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
temp=$(awk -v column=$column '{print $column}' .star1line.dat)
#Convert scientific notation if present
temp1=`echo ${temp} | sed -e 's/[eE]+*/\\*10\\^/'`
mag=$(bc <<< "scale=0; ${temp1}/1")

#echo $value
apix=$(bc <<< "scale=3; ${dstep}*10000/${mag}")

#Get defocus column and calculate minimum and maximum defocus
columnname=rlnDefocusU
column=$(grep ${columnname} ${star1} | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
temp=$(awk -v column=$column '{print $column}' .star1lines.dat | sort -n | head -n 1)
mindf=$(bc <<< "scale=0; ${temp}/10")
temp=$(awk -v column=$column '{print $column}' .star1lines.dat | sort -n | tail -n 1)
maxdf=$(bc <<< "scale=0; ${temp}/10")

echo '###############################################################'
echo 'File:           ' $star1
echo 'Relion version: ' $version
echo ''
echo 'Number of header lines in star file:           ' $headerlines
echo 'Number of data/ptcl lines in star file:        ' $ptcllines
echo ''
echo 'Number of unique micrographs in star file:     ' $miclines
echo 'Number of image groups in star file:           ' $grouplines
echo 'Number of classes in star file:                ' $classlines
echo ''
echo 'Particles per micrograph in star file:         ' $ptclpermic
echo 'Particles per class in star file:              ' $ptclperclass
echo ''
echo 'Physical detector pixel size in star file (µm):' $dstep
echo 'Magnification in star file (X):                ' $mag
echo 'Calculated pixel size (apix):                  ' $apix
echo ''
echo 'Spherical abberation (mm):                     ' $cs
echo ''
echo 'Minimum defocus (nm):                          ' $mindf
echo 'Maximum defocus (nm):                          ' $maxdf
echo '##############################################################'

rm -rf .star1header.dat
rm -rf .star1lines.dat
rm -rf .star1line.dat

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
