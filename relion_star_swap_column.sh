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

star1in=$1
star1col=$2
star2in=$3
star2col=$4

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] ; then

  echo ""
  echo "Variables empty, usage is relion_star_swap_column (1) (2) (3) (4)"
  echo ""
  echo "(1) = starin"
  echo "(2) = starin column number to swap to"
  echo "(3) = starin"
  echo "(4) = starin column number to swap from"
  echo ""
  exit

fi


awk -v v1=$star1col -v v2=$star2col 'FNR==NR{a[NR]=$v2;next}{$v1=a[FNR]}1' $star2in $star1in
