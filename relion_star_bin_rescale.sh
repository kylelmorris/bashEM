#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of Berkeley 2016
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

star=$1
scale=$2
namein=$3
nameout=$4
starout=$5

## Check inputs
if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] || [[ -z $5 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_star_bin_rescale.sh (1) (2) (3) (4) (5)"
  echo ""
  echo "(1) = Input star file"
  echo "(2) = Scale factor i.e. bin1p5 to bin1 = 1.5"
  echo "(3) = Search term to replace i.e. for old particle stacks"
  echo "(4) = Replace term"
  echo "(5) = Output star file"
  echo ""

  exit

fi

#Get headers column numbers
pixsize=$(grep _rlnDetectorPixelSize $star | awk '{print $2}' | sed 's/#//g')
originX=$(grep _rlnOriginX $star | awk '{print $2}' | sed 's/#//g')
originY=$(grep _rlnOriginY $star | awk '{print $2}' | sed 's/#//g')

#Report column tables found
echo ''
echo 'Identified column numbers in:' $star
echo 'rlnDetectorPixelSize #:      ' $pixsize
echo 'rlnOriginX #:                ' $originX
echo 'rlnOriginY #:                ' $originY

#Process star file and change bin
cat $star | awk -v px=${pixsize} -v sc=${scale} -v oriX=${originX} -v oriY=${originY} '{if (NF<7) {print} else {$px=$px/sc; $oriX=sc*$oriX; $oriY=sc*$oriY; print} }' | sed "s/${namein}/${nameout}/g" > $starout

echo ''
echo 'Star file input:             ' $star
echo 'Scaled px size and OriginX/Y:' $scale
echo 'Searched for:                ' $namein
echo 'Replaced with:               ' $nameout
echo 'Star file output:            ' $starout
echo ''

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
