#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# eBIC Diamond Light Source 2022
# MRC LMS 2019
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
outdir=$2

if [[ -z $1 ]] ; then

  echo ""
  echo "Variables empty, usage is: "
  echo ""
  echo "$(basename $0) (1) (2)"
  echo ""
  echo "(1) = Input star file"
  echo "(2) = Output directory (optional)"
  echo ""
  exit

fi

# Error handling on input
if [[ -z $(echo $starin | grep star) ]] ; then
  echo 'Input star file is lacking star file extension...'
  echo 'Exiting, check input...'
  echo ''
  exit
fi

# Test if star file is present
if [[ -e $starin ]] ; then
  echo 'Star file found...'
  echo ''
else
  echo 'Star file not found, exiting...'
  echo ''
  exit
fi

# Directory and folder names
ext=$(echo ${starin##*.})
name=$(basename $starin .${ext})
dir=$(dirname $starin)

# Set up for output of coordinate files
if [[ -z $outdir ]] ; then
  mkdir -p ${dir}/coordinates
  outdir=${dir}/coordinates
else
  mkdir -p ${outdir}
fi

# Extract star data
relion.star_data_extract.sh $starin

# Define file name outputs
mainDataHeader=".star_data_extract/mainDataHeader.dat"
opticsDataHeader=".star_data_extract/opticsDataHeader.dat"
opticsDataLines=".star_data_extract/opticsDataLines.dat"
mainDataLines=".star_data_extract/mainDataLines.dat"
mainDataLine=".star_data_extract/mainDataLine.dat"

#Calculate number of particles by data lines minus header
totallines=$(wc -l $mainDataLines | awk {'print $1'})
headerlines=$(wc -l $mainDataHeader | awk {'print $1'})
ptcllines=$(wc -l $mainDataLines | awk {'print $1'})

#Calculate number of micrographs
columnname=rlnMicrographName
column=$(grep ${columnname} $mainDataHeader | awk '{print $2}' | sed 's/#//g')
#echo $columnname 'is column number:' $column
miclines=$(awk -v column=$column '{print $column}' $mainDataLines | sort -u | wc -l | awk {'print $1'})
awk -v column=$column '{print $column}' $mainDataLines | sort -u  > .miclines.dat

#Calculate ptcls per micrograph in star file
ptclpermic=$(bc <<< "scale=0; ${ptcllines}/${miclines}")

# Coordinate column names
coord1=rlnCoordinateX
coord2=rlnCoordinateY
coord3=rlnAnglePsi
coord4=rlnClassNumber
coord5=rlnAutopickFigureOfMerit

#Get column number in star file
column1=$(grep ${coord1} $mainDataHeader | awk '{print $2}' | sed 's/#//g')
columnname1=$(grep ${coord1} $mainDataHeader | awk '{print $1}' | sed 's/#//g')
column2=$(grep ${coord2} $mainDataHeader | awk '{print $2}' | sed 's/#//g')
columnname2=$(grep ${coord2} $mainDataHeader | awk '{print $1}' | sed 's/#//g')
column3=$(grep ${coord3} $mainDataHeader | awk '{print $2}' | sed 's/#//g')
columnname3=$(grep ${coord3} $mainDataHeader | awk '{print $1}' | sed 's/#//g')
column4=$(grep ${coord4} $mainDataHeader | awk '{print $2}' | sed 's/#//g')
columnname4=$(grep ${coord4} $mainDataHeader | awk '{print $1}' | sed 's/#//g')
column5=$(grep ${coord5} $mainDataHeader | awk '{print $2}' | sed 's/#//g')
columnname5=$(grep ${coord5} $mainDataHeader | awk '{print $1}' | sed 's/#//g')
#echo 'Column name to plot:         ' $columnname1
#echo "Column number:                #${column1}"
#echo 'Column name to plot:         ' $columnname2
#echo "Column number:                #${column2}"
#echo 'Column name to plot:         ' $columnname3
#echo "Column number:                #${column3}"
#echo 'Column name to plot:         ' $columnname4
#echo "Column number:                #${column4}"
#echo 'Column name to plot:         ' $columnname5
#echo "Column number:                #${column5}"
#echo ''

#Set up header for coordinates star files
echo "" > .coord_header.star
echo "data_" >> .coord_header.star
echo "" >> .coord_header.star
echo "loop_" >> .coord_header.star
echo "_rlnCoordinateX #1" >> .coord_header.star
echo "_rlnCoordinateY #2" >> .coord_header.star
echo "_rlnAnglePsi #3" >> .coord_header.star
echo "_rlnClassNumber #4" >> .coord_header.star
echo "_rlnAutopickFigureOfMerit #5" >> .coord_header.star

#Loop through micrographs
while read p ; do
  #Parse micrograph name for naming coordinate file
  ext=$(echo ${p##*.})
  name=$(basename $p .${ext})
  #Pull star file data lines containing current micrograph
  grep $p $mainDataLines | awk -v OFS='\t' -v pickx=${column1} -v picky=${column2} -v psi=${column3} -v class=${column4} -v FOM=${column5} '{print $pickx,$picky,$psi,$class,$FOM}' > .coorddata.star
  #Combine coordinate header with coordinate data for this micrograph
  cat .coord_header.star .coorddata.star > ${outdir}/${name}_manualpick.star
done < .miclines.dat

echo '###############################################################'
echo 'File:           ' $starin
echo 'Relion version: ' $version
echo ''
echo 'Number of header lines in star file:           ' $headerlines
echo 'Number of data/ptcl lines in star file:        ' $ptcllines
echo ''
echo 'Number of unique micrographs in star file:     ' $miclines
echo ''
echo 'Particles per micrograph in star file:         ' $ptclpermic
echo ''
echo 'Individual coordinate star file output:        ' ${outdir}
echo '###############################################################'

# Tidy up
rm -rf .star1*
rm -rf .coord*

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
