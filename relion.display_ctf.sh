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

rm -rf display_ctf_image.mrc

ctfin=$1
scale=$2

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_display_ctf.sh (1) (2)"
  echo ""
  echo "(1) = ctf image in"
  echo "(2) = display scale"
  echo ""
  exit

fi

echo 'Making link to:' $ctfin
ln -s $ctfin display_ctf_image.mrc

echo 'Display using relion_display --i display_ctf_image.mrc --scale' $scale
echo ''
relion_display --i display_ctf_image.mrc --scale $scale

echo 'Tidying up'
echo ''
rm -rf display_ctf_image.mrc

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
