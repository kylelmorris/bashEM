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

# Test if Relion is sourced and available
command -v relion >/dev/null 2>&1 || { echo >&2 "Relion does not appear to be installed or loaded..."; exit 1; }

## Import command line variables
starin=$1

##Test if input variables are empty (if or statement)
echo ""
echo "Usage is $(basename $0) (1)"
echo ""
echo "(1) = relion_locres_fscs.star file containing locres fsc curves"
echo ""

# Directory and folder names
ext=$(echo ${starin##*.})
name=$(basename $starin .${ext})
dir=$(dirname $starin)

## Change directory to where *.star file resides
cwd=$(pwd)
cd $dir

## Split star file into individual fsc data
awk '/data_fsc/{n++}{print >"relion_locres_fsc_" n ".star" }' ${starin}
mkdir locres_fscs
mv relion_locres_fsc_*star locres_fscs
cd locres_fscs
rm -rf relion_locres_fsc_.star

## report command that can be used for plotting
echo "You can use the following to plot all fsc curves individually"
echo "for f in *star; do relion.plot_fsc.sh $f ; done"
