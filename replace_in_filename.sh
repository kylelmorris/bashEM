#!/bin/bash
#
#
############################################################################
#
# Author: "Kyle L. Morris"
# University of California Berkeley 2017
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

find=$1
replace=$2

echo ''
echo 'Usage:'
echo 'replace_in_filename find_string replace_string'
echo ''

if [[ -z $1 ]] ; then
  echo "No find term provided, exiting..."
  exit
fi

echo 'Executing the following command:'
echo ''
echo 'for i in * ; do mv "$i" "${i/"${find}"/"${replace}"}" ; done'
echo ''
echo '{find}:   ' $find
echo '{replace}:' $replace
echo ''
echo 'Hit Enter to confirm execution or ctrl-c to quit and try again...'
read p

for i in * ; do mv "$i" "${i/${find}/${replace}}" ; done
#echo "find . -depth -name '*$find*' -execdir bash -c 'for f; do mv -i \"\$f\" \"\${f//$find/$replace}\"; done' bash {} +"
echo ''
