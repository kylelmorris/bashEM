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


box=$1
suffix=$2

#Test if input variables are empty (if or statement)
if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is resample_batch.sh (1) (2)"
  echo ""
  echo "(1) = new resample box size"
  echo "(2) = new suffix to append"
  echo ""

  exit

fi

#Creates file list
ls -n *.mrc | awk {'print $9'} | cat -n > filelist.dat

#Gets number of files
a=$(wc -l filelist.dat | awk {'print $1'})
echo $a '.mrc files to resample'

#Removes .mrcs file extension from filelist.dat
sed 's/.mrc//g' filelist.dat > tmp.dat
mv -f tmp.dat filelist.dat

#Loops through using filelist.dat
for ((i=1; i<=a; i++))
do
  name=$(sed -n "$i"p filelist.dat | awk {'print $2'})
  echo 'Resample:' $name
  ln -s $name".mrc" $name".mrc"
  new=$(echo $name$suffix)

resamplename=$(echo $name".mrc")
resamplenew=$(echo $new".mrc")
#Resample.exe code
resample.exe <<- EOF
$resamplename
$resamplenew
NO
NO
$box
$box
EOF

done

#Removes filelist.dat
rm filelist.dat

echo "//////////////////////"
echo "File conversion complete"
echo "//////////////////////"

ls -han *.mrc
