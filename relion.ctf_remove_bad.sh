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
# Remove bad ctf outliers from star file
##

starin=$1
starctf=$2

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_ctf_remove_bad.sh (1) (2)"
  echo ""
  echo "(1) = star in"
  echo "(2) = bad ctf estimation list"
  echo ""
  exit

fi

rm -rf *.dat

#grep "VALIDATION_SCORE: 2\|VALIDATION_SCORE: 1" *log | awk '{print $1}' | sed 's/Raw_gctf.log://g' > $starctf

while read p; do
  #grep $p $starin
  echo 'Removing micrograph:' $p
  sed -i "/$p/d" $starin
done < $starctf

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
