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

echo "*************************************************************************************"
echo "Gautomatch coordinate import, Kyle Morris University of California Berkeley 2016"
echo ""
echo "This script imports/copies gautomatch *automatch.star coordinates to the proper"
echo "directory of a pre-existing Relion manual pick directory for use in Relion"
echo ""
echo "Note: This will overwrite preexisting *pick_star.manual coords so back up first if"
echo "you care about them"
echo "*************************************************************************************"

#Variable inputs
gautocoords=$1
manualcoords=$2

cwd=$(pwd)

# Test if input variables are empty (if or statement)
echo ""
echo "Usage is relion_import_gautomatch (1) (2)"
echo ""
echo "(1) = Path to directory of gautomatch coordinates"
echo "(2) = Path to directory of Relion manual pick coordinates"
echo ""

if [[ -z $1 ]] || [[ -z $2 ]] ; then
  echo ""
  echo "No variables provided, check inputs"
  echo ""
  exit
fi

#rm -rf ${manualcoords}/*manualpick.star
#scp -r ${gautocoords}/*autopick.star ${manualcoords}/

cd ${manualcoords}/
#find . -depth -name '*autopick*' -execdir bash -c 'for f; do mv -i "$f" "${f//autopick/manualpick}"; done' bash {} +

cd $cwd

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
