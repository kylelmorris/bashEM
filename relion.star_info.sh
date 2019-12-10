#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of Warwick 2016
# MRC London Institute of Medical Sciences 2019
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
  echo ''
  echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
  echo 'Star file found...'
  echo ''
else
  echo ''
  echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
  echo 'Star file not found, exiting...'
  echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
  echo ''
  exit
fi

# Tidy up from previous execution
rm -rf .star1header.dat

################################################################################
# Get header and data lines
################################################################################

##As of relion3 a version header is included in star file, ascertain for reporting and removal
versionSearch=$(cat ${star1} | grep "version" | head -n 1)

if [[ -z ${versionSearch} ]] ; then
  version=$(echo "No Relion version header found...")
  versionSearch="Unknown"
  #### INSERT CODE HERE TO CREATE A FAKE OPTICS GROUP FILE FOR READING PIXEL SIZE ETC ####
else
  version=$(echo "Relion version: ${versionSearch}")
fi

echo $version
echo ""

##The following code implements a new way to find relion star file headers since version 3.1 changes
# Find data_ blocks
dataBlocks=$(grep -n data_ ${star1} | sed 's/:/ /g')

echo "Found the following number of data_ blocks in header: $(echo "$dataBlocks" | wc -l)"
echo ""

# Report data_ block names without line numbers
echo "$dataBlocks" | awk '{print "\t",$2,"(@ line: "$1")"}'
echo ""

# Store data_optics line number
opticsDataBlockNo=$(echo "$dataBlocks" | head -n 1 | awk '{print $1}')
# Store main data_ block line number
mainDataBlockNo=$(echo "$dataBlocks" | tail -n 1 | awk '{print $1}')

# Store the first optic line (i.e. containing > 3 columns) after first data_optics block
opticsDataLine=$(cat ${star1} | awk -v opticsDataBlockNo=$opticsDataBlockNo 'NR>=opticsDataBlockNo' | awk 'NF > 3' | head -n 1)
# Find the first dataline number
opticsDataLineNo=$(grep -n "${opticsDataLine}" ${star1} | sed 's/:/ /g' | awk '{print $1}')
echo "First optics line appears on line no: ${opticsDataLineNo}"

# Store the first data line (i.e. containing > 3 columns) after final data_ block
mainDataLine=$(cat ${star1} | awk -v mainDataBlockNo=$mainDataBlockNo 'NR>=mainDataBlockNo' | awk 'NF > 3' | head -n 1)
# Find the first dataline number
mainDataLineNo=$(grep -n "${mainDataLine}" ${star1} | sed 's/:/ /g' | awk '{print $1}')
echo "First data line appears on line no: ${mainDataLineNo}"

# Save optics group to file and clean up header
cat ${star1} | sed -n ${opticsDataBlockNo},${mainDataBlockNo}p | sed "/${versionSearch}/Q" | awk 'NF < 3' > .opticsDataHeader.dat
# Save optics group to file and clean up header
cat ${star1} | sed -n ${opticsDataBlockNo},${mainDataBlockNo}p | sed "/${versionSearch}/Q" | awk 'NF > 3' > .opticsDataLines.dat
# Save mainDataBlock header
cat ${star1} | sed -n ${mainDataBlockNo},${mainDataLineNo}p | sed "/${versionSearch}/Q" | sed '$ d' > .mainDataHeader.dat
# Save mainDataLines, remove blank lines
cat ${star1} | sed -n "${mainDataLineNo},$ p" | sed '/^\s*$/d' > .mainDataLines.dat
# Save a single line of star1 for certain calculations
sed -n '1p' .mainDataLines.dat > .mainDataLine.dat

# Files for diagnostics
#scp .opticsDataHeader.dat opticsDataHeader.dat
#scp .opticsDataLines.dat opticsDataLines.dat
#scp .mainDataHeader.dat mainDataHeader.dat
#scp .mainDataLines.dat mainDataLines.dat
#scp .mainDataLine.dat mainDataLine.dat

echo '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
echo ""

################################################################################
# Process star file
################################################################################

#Calculate number of particles by data lines minus header
totallines=$(wc -l $star1 | awk {'print $1'})
#mainHeaderLines=$(wc -l .mainDataHeader.dat | awk {'print $1'})
mainDataLines=$(wc -l .mainDataLines.dat | awk {'print $1'})
#opticsHeaderLines=$(wc -l .opticsDataHeader.dat | awk {'print $1'})
opticsLines=$(wc -l .opticsDataLines.dat | awk {'print $1'})

#Calculate number of micrographs
columnname=rlnMicrographName
column=$(grep ${columnname} .mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
miclines=$(awk -v column=$column '{print $column}' .mainDataLines.dat | sort -u | wc -l | awk {'print $1'})

#Calculate number of image groups
columnname=rlnGroupNumber
column=$(grep ${columnname} .mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
grouplines=$(awk -v column=$column '{print $column}' .mainDataLines.dat | sort -u | wc -l | awk {'print $1'})

#Calculate number of classes
columnname=rlnClassNumber
column=$(grep ${columnname} .mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
classlines=$(awk -v column=$column '{print $column}' .mainDataLines.dat | sort -u | wc -l | awk {'print $1'})

#Calculate ptcls per micrograph in star file
ptclpermic=$(bc <<< "scale=0; ${mainDataLines}/${miclines}")

#Calculate ptcls per class in star file
ptclperclass=$(bc <<< "scale=0; ${mainDataLines}/${classlines}")

#Find cs (mm)
columnname=rlnSphericalAberration
column=$(grep ${columnname} .opticsDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
cs=$(awk -v column=$column '{print $column}' .opticsDataLines.dat | head -n 1)

#Calculate pixel size, note micrograph and particle files use rlnMicrographPixelSize and rlnImagePixelSize respectively
columnname=ImagePixelSize
#Assess whether this is a micrograph or particle star file
columnEntry=$(grep ${columnname} .opticsDataHeader.dat |  awk '{print $1}')

column=$(grep ${columnname} .opticsDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
apix=$(awk -v column=$column '{print $column}' .opticsDataLines.dat | head -n 1)

#Get defocus column and calculate minimum and maximum defocus
columnname=rlnDefocusU
column=$(grep ${columnname} .mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
tmp=$(awk -v column=$column '{print $column}' .mainDataLines.dat | sort -n | head -n 1)
mindf=$(bc <<< "scale=0; ${tmp}/10")
tmp=$(awk -v column=$column '{print $column}' .mainDataLines.dat | sort -n | tail -n 1)
maxdf=$(bc <<< "scale=0; ${tmp}/10")

echo '###############################################################'
echo '## Relion star file information ###############################'
echo '###############################################################'
echo ''
echo 'File:           ' $star1
echo 'Relion version: ' $versionSearch
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
echo '##############################################################'

rm -rf .*.dat

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
