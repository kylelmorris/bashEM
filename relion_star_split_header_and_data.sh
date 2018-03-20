#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of Berkeley 2017
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

if [[ -z $1 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_star_split_header_and_data.sh (1)"
  echo ""
  echo "(1) = star in"
  echo ""
  exit

fi

#Make sure directory is clean
rm -rf star1header.dat
rm -rf tmp.dat
rm -rf star1header_trimcol.dat
rm -rf star1lines.dat
rm -rf star1datalines.dat

# Split starin into header and data lines
awk '{if (NF > 3) exit; print }' < ${starin} > star1header.dat
awk '{print $1,$2}' star1header.dat | sed '1,4d' > tmp.dat
mv tmp.dat star1header_trim.dat
awk '{print $1}' star1header_trim.dat > star1header_trimcol.dat
diff star1header.dat ${starin} | awk '!($1="")' > star1lines.dat
sed '1d' star1lines.dat > tmp.dat
awk 'NF' tmp.dat > star1datalines.dat

rm -rf tmp.dat
