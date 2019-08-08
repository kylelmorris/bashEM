#!/usr/bin/env bash
#

starin=$1
seldir=$2
select=$3
columnname="_rlnMicrographName"

## Test for input variables
if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] ; then
  echo ""
  echo "Variables empty, usage is $(basename $0) (1) (2) (3)"
  echo ""
  echo "(1) = micrograph star file"
  echo "(2) = select folder containing selected mics (i.e. in png)"
  echo "(3) = select folder is good (1) or bad (0)?"
  echo ""

  exit
fi

## Clear last line
#https://stackoverflow.com/questions/11283625/overwrite-last-line-on-terminal
function clearLastLine() {
        tput cuu 1 && tput el
}

## Directory and folder names for star file
ext=$(echo ${starin##*.})
name=$(basename $starin .${ext})
dir=$(dirname $starin)

## Get column number in star file
echo ''
echo 'star file in:                ' $starin
echo 'Column name to plot:         ' $columnname
echo ''
column=$(grep ${columnname} ${starin} | awk '{print $2}' | sed 's/#//g')
columnname=$(grep ${columnname} ${starin} | awk '{print $1}' | sed 's/#//g')
echo "Column number:                #${column}"
echo ''

## Get list of selected mics from select Directory
ls ${seldir} > ${dir}/.miclist.dat

## Get header and data lines of Micrograph star file
#Get header of star
awk 'NF < 3' < ${starin} > ${dir}/.star1header.dat
#As of relion3 a version header is included in star file, ascertain for reporting and removal
search=$(grep "# RELION; version" ${starin})
echo $search
if [[ -z ${search} ]] ; then
  version=$(echo "Pre Relion-3, no version header found...")
  diff ${dir}/.star1header.dat ${starin} | awk '!($1="")' > ${dir}/.star1lines.dat
else
  version=$(echo ${search})
  diff ${dir}/.star1header.dat ${starin} | sed "/${version}/d" | awk '!($1="")' > ${dir}/.star1lines.dat
fi
#Remove blank lines in data line file
sed -i '/^$/d' ${dir}/.star1lines.dat
#Calculate number of particles by data lines minus header
totallines=$(wc -l $starin | awk {'print $1'})
headerlines=$(wc -l ${dir}/.star1header.dat | awk {'print $1'})
datalines=$(wc -l ${dir}/.star1lines.dat | awk {'print $1'})

## Loop through star file and filter micrographs
echo "" > ${dir}/.star1lines_filtered.dat
i=1
#Read lines of unique GridSquares and find the grid square image for these
while read p ; do
  # Do line coutning and update progress
  echo -e "Filtering star file dataline: ${i}/${datalines}"

  # Extract _rlnMicrographName from data line stroed in ${p}, and remove path and ext
  micname=$(basename $(echo ${p} | awk -v column=$column '{print $column}') .mrc)
  # Filter based on good/bad setting
  search=$(grep ${micname} ${dir}/.miclist.dat)

  # If selected mics are good and mic found in miclist.dat then carry over
  if [[ $select == 1 ]] && [[ ! -z $search ]]; then
    echo ${p} >> ${dir}/.star1lines_filtered.dat
  fi
  # If selected mics are bad and mic not found in miclist.dat then carry over
  if [[ $select == 0 ]] && [[ -z $search ]]; then
    echo ${p} >> ${dir}/.star1lines_filtered.dat
  fi

  i=$((i+1))
  clearLastLine
done < ${dir}/.star1lines.dat

## Write a new filtered star file
cat ${dir}/.star1header.dat ${dir}/.star1lines_filtered.dat > ${dir}/micrographs_filtered.star

## Tidy up
rm -rf ${dir}/.star1*
rm -rf ${dir}/.miclist*
