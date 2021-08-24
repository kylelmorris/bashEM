#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of Warwick 2016
# MRC London Institute of Medical Sciences 2019
# Diamond Light Source 2021
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
if [[ -e $starin ]] ; then
  echo ''
  echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
  echo 'Star file found...'
  echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
  echo ''
else
  echo ''
  echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
  echo 'Star file not found, exiting...'
  echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
  echo ''
  exit
fi

dirout=$(echo ".star_info")

# As of Relion3 star file formatting changed
# Use relion.star_extract_data.sh to extract data and header lines
# Assumes all of bashEM repository is in $PATH
relion.star_extract_data.sh ${starin} ${dirout}

################################################################################
# Process star file
################################################################################

#Read the version
versionSearch=$(cat ${dirout}/.version.dat)

#Calculate number of particles by data lines minus header
totallines=$(wc -l $starin | awk {'print $1'})
#mainHeaderLines=$(wc -l .mainDataHeader.dat | awk {'print $1'})
mainDataLines=$(wc -l ${dirout}/.mainDataLines.dat | awk {'print $1'})
#opticsHeaderLines=$(wc -l .opticsDataHeader.dat | awk {'print $1'})
opticsLines=$(wc -l ${dirout}/.opticsDataLines.dat | awk {'print $1'})

#Calculate number of micrographs
columnname=rlnMicrographName
column=$(grep ${columnname} ${dirout}/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
miclines=$(awk -v column=$column '{print $column}' ${dirout}/.mainDataLines.dat | sort -u | wc -l | awk {'print $1'})

#Calculate number of image groups
columnname=rlnGroupNumber
column=$(grep ${columnname} ${dirout}/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
grouplines=$(awk -v column=$column '{print $column}' ${dirout}/.mainDataLines.dat | sort -u | wc -l | awk {'print $1'})

#Calculate number of classes
columnname=rlnClassNumber
column=$(grep ${columnname} ${dirout}/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
classlines=$(awk -v column=$column '{print $column}' ${dirout}/.mainDataLines.dat | sort -u | wc -l | awk {'print $1'})

#Calculate ptcls per micrograph in star file
ptclpermic=$(bc <<< "scale=0; ${mainDataLines}/${miclines}")

#Calculate ptcls per class in star file
ptclperclass=$(bc <<< "scale=0; ${mainDataLines}/${classlines}")

#Find cs (mm)
columnname=rlnSphericalAberration
column=$(grep ${columnname} ${dirout}/.opticsDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
cs=$(awk -v column=$column '{print $column}' ${dirout}/.opticsDataLines.dat | head -n 1)

#Calculate pixel size, note micrograph and particle files use rlnMicrographPixelSize and rlnImagePixelSize respectively
columnname=ImagePixelSize
#Assess whether this is a micrograph or particle star file
columnEntry=$(grep ${columnname} ${dirout}/.opticsDataHeader.dat |  awk '{print $1}')

column=$(grep ${columnname} ${dirout}/.opticsDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
apix=$(awk -v column=$column '{print $column}' ${dirout}/.opticsDataLines.dat | head -n 1)

#Get defocus column and calculate minimum and maximum defocus
columnname=rlnDefocusU
column=$(grep ${columnname} ${dirout}/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
tmp=$(awk -v column=$column '{print $column}' ${dirout}/.mainDataLines.dat | awk NF | sort -n | head -n 1)
mindf=$(bc <<< "scale=0; ${tmp}/10")
tmp=$(awk -v column=$column '{print $column}' ${dirout}/.mainDataLines.dat | awk NF | sort -n | tail -n 1)
maxdf=$(bc <<< "scale=0; ${tmp}/10")

echo ''
echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
echo 'Relion star file information '
echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
echo ''
echo 'File:                                          ' $starin
echo 'Relion version:                                ' $versionSearch
echo ''
#echo 'Number of main data header lines in star file: ' $mainHeaderLines
echo 'Number of data/ptcl lines in star file:        ' $mainDataLines
#echo ''
#echo 'Number of optics groups header lines:          ' $opticsHeaderLines
echo 'Number of optics groups in star file:          ' $opticsLines
echo ''
echo 'Number of unique micrographs in star file:     ' $miclines
echo 'Number of image groups in star file:           ' $grouplines
echo 'Number of classes in star file:                ' $classlines
echo ''
echo 'Particles per micrograph in star file:         ' $ptclpermic
echo 'Particles per class in star file:              ' $ptclperclass
echo ''
echo 'Calibrated pixel size (apix):                  ' $apix
echo ''
echo 'Spherical abberation (mm):                     ' $cs
echo ''
echo 'Minimum defocus (nm):                          ' $mindf
echo 'Maximum defocus (nm):                          ' $maxdf
echo ''
echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'

rm -rf .*.dat

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
