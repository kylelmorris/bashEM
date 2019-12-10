#!/bin/bash

#
#
############################################################################
#
# Author: "Kyle L. Morris"
# MRC London Institute of Medical Sciences 2019
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

starin=$1
listfiltby=$2

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is $(basename $0) (1) (2) (3)"
  echo ""
  echo "(1) = star to filter"
  echo "(2) = list to filter by"
  echo ""
  exit

fi

#Useful messages
echo ''
echo 'star to filter:     ' $starin
echo 'list to filter by:  ' $listfiltby
echo ''

#Filter star file by data that exists in filter by star file
i=1
while [ $i -le $(wc -l $listfiltby | awk {'print $1'}) ] ; do
  grep $(sed -n ${i}p $listfiltby) $starin >> tmp.dat
  echo -en 'Working on line' $i 'of' $(wc -l $listfiltby | awk {'print $1'}) \\r
  i=$((i+1))
done

mv tmp.dat star_filtered.star

rm -rf *dat

# Finish
echo "This is a simple search and filter script..."
echo "It does not deal with Relion headers currently..."
echo "Check output and add relion header back."
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
