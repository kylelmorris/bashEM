#!/usr/bin/env bash
#

# Written by Kyle Morris 2019

#Variables
exec=lbzip2
#Variables, user
ext=$1
dir=$2
depth=$3
thread=$4

# Test if program is sourced and available
command -v ${exec} >/dev/null 2>&1 || { echo >&2 "${exec} does not appear to be installed or sourced..."; exit 1; }

#Variables test
if [[ -z $1 ]]; then
  echo ""
  echo "No inputs specified... exiting"
  echo ""
  echo "$(basename $0) (1) (2) (3) (4)"
  echo "(1) = extension"
  echo "(2) = directory to search (optional)"
  echo "(3) = directory depth to search (optional)"
  echo "(4) = cpu threading number (optional)"
  echo ""
  exit
fi

if [[ -z $2 ]] ; then
  dir="."
fi

if [[ -z $3 ]] ; then
  depth=1
fi

if [[ -z $4 ]] ; then
  thread=1
fi

# Find files
find ${dir} -maxdepth $depth -wholename "*${ext}" > ${dir}/.files.dat

# Useful information and continue
fileno=$(wc -l ${dir}/.files.dat | awk '{print $1}')
echo ""
echo "File extension:            ${ext}"
echo "Directory search location: ${dir}"
echo "Directory search depth:    ${depth}"
echo "Number of CPU threads:     ${thread}"
echo "Number of files identified for compression: ${fileno}"
echo "Press Enter to continue or ctrl-c to quit..."
echo ""
read p

i=1

# Loop through files
while read f ; do

  # Information
  echo ""
  echo "Working on file: ${i}/${fileno}"
  echo ""

  # Compression execution
  lbzip2 -n ${thread} -v $f

  # Advance the loop counter
  i=$(($i+1))

done < ${dir}/.files.dat

# Tidy up
rm -rf ${dir}/.files.dat

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
