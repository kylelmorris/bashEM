#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of California Berkeley 2016
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

############################################################################
# TO DO
# Should change this so it produces a .com file for each mic, then executes
# This way you can have it use variables, in current EOF format below variables don't work
############################################################################

# Purpose
# defocus estimation with ctftilt v3 on directory of micrographs

# Get all ctffind parameters from user
echo -n "executable location:"
echo ""
read ctffind

# loop through all mrc files in directory and execute ctf executable
for i in *.mrc
do

# get file rootname without extension
filename=$(basename $i .mrc)
filein=$(echo $filename".mrc")
fileout=$(echo $filename".ctf")
filelog=$(echo $filename"_ctffind3.log")

# actual ctffind execution code
$ctffind <<EOF > $filelog
$filein
$fileout
6.3 120 0.15 72897.19 15.6 2 #$cs $voltage $ac $XMAG $dstep $PAve
512 30 5 5000 30000 500 100 15 2.5 #$box $minA $maxA $mindf $maxdf $step $ast $tilt $tiltsd
EOF

strings $filelog > tmp.log
mv tmp.log $filelog

done

# Show final values
strings *log | grep Final

#echo -n "number of threads to use"
#echo ""
#read nthreads
#echo -n "apix:"
#echo ""
#read apix
#echo -n "voltage:"
#echo ""
#read voltage
#echo -n "cs (mm):"
#echo ""
#read cs
#echo -n "ac:"
#echo ""
#read ac
#echo -n "dtsep (um):"
#echo ""
#read dstep
#echo -n "Pixel averaging (i.e. 1-2):"
#echo ""
#read PAve
#echo -n "box / px (i.e. 512):"
#echo ""
#read box
#echo -n "resolution estimate min / A (i.e. 50):"
#echo ""
#read minA
#echo -n "resolution estimate max / A (i.e. 5):"
#echo ""
#read maxA
#echo -n "min defocus / A (i.e. 5000):"
#echo ""
#read mindf
#echo -n "max defocus / A (i.e. 60000)"
#echo ""
#read maxdf
#echo -n "search step / A (i.e. 500)"
#echo ""
#read step
#echo -n "ast (i.e. 100)"
#echo ""
#read ast
#echo -n "tilt (deg):"
#echo ""
#read tilt
#echo -n "tilt error estimate (deg):"
#echo ""
#read tiltsd

# Do non integer magnification calculation
#XMAG=$(echo "scale=2; ($dstep*10000)/$apix" | bc)

echo ""
echo "#############################################################"
echo "################# CTFTILT3 control script ###################"
echo "############# Kyle Morris, UC Berkeley 2016 #################"
echo "#############################################################"
echo ""
echo "Executable location:"
echo $ctffind
echo ""
#NCPUS=$(echo $nthreads)
#echo "nthreads:" $NCPUS
#echo ""
#echo "apix    "$apix
#echo "V       "$voltage
#echo "cs      "$cs
#echo "ac      "$ac
#echo "dstep   "$dstep
#echo "PAve    "$PAve
#echo "box     "$box
#echo "minA    "$minA
#echo "maxA    "$maxA
#echo "minDF   "$mindf
#echo "maxDF   "$maxdf
#echo "stepDF  "$step
#echo "astig   "$ast
#echo "tilt    "$tilt
#echo "tilt+/- "$tiltsd
#echo ""
#echo "Xmag    "$XMAG
#echo ""
#echo ""
#echo "#########################################################"
#echo -n "If all parameters are correct, type y and continue..."
#read continue




