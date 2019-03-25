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

starin=$1

if [[ -z $1 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_star_print_header.sh (1)"
  echo ""
  echo "(1) = star in"
  echo ""
  exit

fi

awk '{if (NF > 3) exit; print }' < $starin

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
