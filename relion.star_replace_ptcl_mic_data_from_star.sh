#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
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

# Variables
starin=$1
starreplace=$2

if [[ -z $1 ]] || [[ -z $2 ]]; then

  echo ""
  echo "Variables empty, usage is $(basename $0) (1) (2)"
  echo ""
  echo "(1) = Particle star file in"
  echo "(2) = Micrograph star file with new micrograph data"
  exit

fi

# Directory for working in
dirout=.star_replace
mkdir -p $dirout

# Make sure directory is clean
#rm -rf $dirout

###############################################################################
# Get column number and data for rlnMicrographName from starreplace
###############################################################################
# Split star file
relion.star_extract_data.sh $starreplace $dirout/starreplace
# Get column names from star replace
micnamecol1=$(grep "rlnMicrographName" $dirout/starreplace/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
micmetadat1=$(grep "rlnMicrographMetadata" $dirout/starreplace/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
micopticsg1=$(grep "rlnOpticsGroup" $dirout/starreplace/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
micaccummt1=$(grep "rlnAccumMotionTotal" $dirout/starreplace/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
micaccumme1=$(grep "rlnAccumMotionEarly" $dirout/starreplace/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
micaccumml1=$(grep "rlnAccumMotionLate" $dirout/starreplace/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')

echo ""
echo "${starreplace} micrograph file columns:"
echo "rlnMicrographName:     $micnamecol1"
echo "rlnMicrographMetadata: $micmetadat1"
echo "rlnOpticsGroup:        $micopticsg1"
echo "rlnAccumMotionTotal:   $micaccummt1"
echo "rlnAccumMotionEarly:   $micaccumme1"
echo "rlnAccumMotionLate:    $micaccumml1"
echo ""

###############################################################################
# Get column number and data for rlnImageName from starin
###############################################################################
# Split star file
relion.star_extract_data.sh $starin $dirout/starin

# Get column names from star in (particles)
ptclimgname=$(grep "rlnImageName" $dirout/starin/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')

# Get number of data lines in particle star file to work on
lineno=$(awk NF $dirout/starin/.mainDataLines.dat | wc -l | awk '{print $1}')

# Remove columns to avoid duplications
relion.star_data_handler.sh -i $starin -o $starin -d rlnMicrographName
relion.star_data_handler.sh -i $starin -o $starin -d rlnOpticsGroup

###############################################################################
# Loop through starin data line by line and look up new defocus values newdefocus.dat
###############################################################################

echo ""
echo "Proceeding to loop through the input: $starin"
echo "Micrograph data from $starreplace will be added to the input star file"
echo "This can take some time..."
echo ""

echo ""
i=1
while read dataline
do
  #Get current line
  current=$(echo $dataline)

  #Get image name from particle star data lines without path and without extension
  tmp=$(echo $dataline | awk -v imgname="$ptclimgname" '{print $imgname}' | grep -oE "[^/]+$")
  imgname=${tmp%.*}

  #Find this micrograph in star replace
  add=$(grep $imgname $dirout/starreplace/.mainDataLines.dat | awk -v a=$micnamecol1 -v b=$micmetadat1 -v c=$micopticsg1 -v d=$micaccummt1 -v e=$micaccumme1 -v f=$micaccumml1 '{print $a,$b,$c,$d,$e,$f}')

  #Store these values in Variables
  new1=$(echo $add | awk '{print $1}')
  new2=$(echo $add | awk '{print $2}')
  new3=$(echo $add | awk '{print $3}')
  new4=$(echo $add | awk '{print $4}')
  new5=$(echo $add | awk '{print $5}')
  new6=$(echo $add | awk '{print $6}')
  new7=$(echo $current)

  #Create new star file line with adding new data from star replace
  #newline=$(echo $dataline)
  #newline=$(echo $dataline | awk -v a=$new1 -v b=$new2 -v c=$new3 -v d=$new4 -v e=$new5 -v f=$new6 '{print a,b,c,d,e,f}')
  newline=$(echo $dataline | awk -v a=$new1 -v b=$new2 -v c=$new3 -v d=$new4 -v e=$new5 -v f=$new6 '{print a,b,c,d,e,f,$0}')
  echo $newline >> datalinesnew.dat

  #Useful information, math on percentage completeness
  pcnt=$(bc <<< "scale=3; $i/$lineno*100")
  #Print percentage completed to terminal
  ceol=$(tput el)
  echo -ne "${ceol}\rCompleted ${pcnt}%"

  i=$((i+1))
done < $dirout/starin/.mainDataLines.dat

# report sanity check stats
echo ""
echo "Number of data lines in original particle star file: "$starin
echo "${lineno}"
echo "Number of data lines in new UVA replaced particle star file:"
echo $(wc -l datalinesnew.dat | awk '{print $1}')
echo ""

# Send header to new star file, followed by each new line with replaced UVA
cat star1header.dat datalinesnew.dat > star_replaced.star

# Useful message

echo ""
echo "Done!"
echo ""

# Tidy up
rm -rf *dat

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""




exit

# Old stuff

# Get column names from star in (particles)
micnamecol2=$(grep "rlnMicrographName" $dirout/starin/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
micmetadat2=$(grep "rlnMicrographMetadata" $dirout/starin/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
micopticsg2=$(grep "rlnOpticsGroup" $dirout/starin/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
micaccummt2=$(grep "rlnAccumMotionTotal" $dirout/starin/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
micaccumme2=$(grep "rlnAccumMotionEarly" $dirout/starin/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')
micaccumml2=$(grep "rlnAccumMotionLate" $dirout/starin/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')

echo ""
echo "${starin} micrograph file columns:"
echo "rlnMicrographName:     $micnamecol2"
echo "rlnMicrographMetadata: $micmetadat2"
echo "rlnOpticsGroup:        $micopticsg2"
echo "rlnAccumMotionTotal:   $micaccummt2"
echo "rlnAccumMotionEarly:   $micaccumme2"
echo "rlnAccumMotionLate:    $micaccumml2"
echo "rlnAccumMotionLate:    $micaccumml2"
