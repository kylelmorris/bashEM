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


moviepartstar=$1
ctfstar=$2

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_movie_add_ctf (1) (2)"
  echo ""
  echo "(1) = particles movie star file"
  echo "(2) = star file with ctf information"
  echo ""
  exit

fi

rm -rf *.dat

awk '{if (NF > 3) exit; print }' < ${moviepartstar} > header.dat
diff header.dat ${moviepartstar} | awk '!($1="")' > movielines.dat
sed '1d' movielines.dat > tmp.dat
mv tmp.dat movielines.dat

awk {'print $5'} movielines.dat > movieparts.dat
j=$(wc -l movieparts.dat | awk {'print $1'})

#echo "test" > movieparts_ctf.dat

#Loops through using movieparts.dat
for ((i=1; i<=j; i++))
do
   echo "Processing line:" $i "of" $j

   search=$(sed -n "$i"p movieparts.dat)
   grep $search $ctfstar | awk {'print $2,$3'} >> ctf.dat
done

paste movielines.dat ctf.dat > movieparts_ctf.dat

echo '_rlnDefocusU #6 ' >> header.dat
echo '_rlnDefocusV #7 ' >> header.dat

cat header.dat movieparts_ctf.dat >> movieparts_ctf.star

rm -rf *.dat

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
