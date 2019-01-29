#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of California Berkeley, 2016
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

if [[ -z $1 ]] || [[ -z $2 ]] ; then
  echo ""
  echo "Variables empty, usage is proc2d_batch (1) (2) (3) (4)"
  echo ""
  echo "(1) = File format in - i.e. dm3"
  echo "(2) = File format out - i.e. mrc"
  echo "Note - no need to include '.' in file extension"
  echo "(3) = enter e2proc2d options here (i.e. --outmode=int8)"
  echo "(4) = enter a new file suffix here (i.e. _int8)"
  echo ""

  exit
fi

#MRC to TIF file conversion using eman2 e2proc2d.py

filein=$1
fileout=$2
option1=$3
suffix=$4

#Creates file list
ls -n *.${filein} | awk {'print $9'} | cat -n > filelist.dat

#Gets number of files
a=$(wc -l filelist.dat | awk {'print $1'})
echo $a '.'${filein}' files to convert'

#Removes file extension from filelist.dat
awk '{print $2}' filelist.dat | sed "s/.$filein//g" > tmp.dat
mv -f tmp.dat filelist.dat

#Loops through using filelist.dat to convert each .dm3 to .mrc using e2proc2d.py
i=1
while read p; do
   j=$(echo "$i"p)

   name=$(sed -n "$i"p filelist.dat)

   infile=$name"."$filein
   outfile=$name"."$fileout

   echo "infile: ${infile}"
   echo "outfile: ${outfile}"

   e2proc2d.py $option1 $infile $outfile
   echo "e2proc2d.py" $option1 $infile $outfile

   i=$((i+1))
done < filelist.dat

#Removes filelist.dat
rm -rf filelist.dat

echo "//////////////////////"
echo "File conversion complete"
echo "//////////////////////"

ls *.${fileout}
