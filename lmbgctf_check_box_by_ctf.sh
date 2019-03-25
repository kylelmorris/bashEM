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

if [[ -z $1 ]] ; then

  echo ""
  echo "Variables empty, usage is lmbctf_check_box_by_ctf.shh (1)"
  echo ""
  echo "(1) = lmbgctf validation score to check by i.e. 5-1"
  echo "5 = Perfect"
  echo "4 = Good"
  echo "3 = Usable"
  echo "2 = Bad"
  echo "1 = Wrong"
  exit

fi

ctf_score=$1

grep "VALIDATION_SCORE: ""$1" *.log | awk {'print $1'} | sed 's/_float_gctf.log:/.box/g' > box_ctf.dat

while read p ;do
  #echo $p
  wc -l ../box-bin1-ctf-screened/$p
  #This will empty those files of box co-ordinates
  rm -rf ../box-bin1-ctf-screened/$p
  touch ../box-bin1-ctf-screened/$p
  wc -l ../box-bin1-ctf-screened/$p
  echo ''
done < box_ctf.dat

echo ''
echo 'Removed box co-ordinates based on ctf validation score: VALIDATION_SCORE:' $ctf_score

rm -rf box_ctf.dat

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
