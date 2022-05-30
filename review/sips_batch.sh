#!/bin/bash
#

if [[ -z $1 ]] || [[ -z $2 ]] ; then
  echo ""
  echo "Variables empty, usage is sips_batch (1) (2)"
  echo ""
  echo "sips_batch (1) (2)"
  echo "extin = (1)"
  echo "extout = (2)"
  echo ""

  exit
fi

extin=$1
extout=$2

# Make filelist
ls -n *.$extin | awk {'print $9'} | cat -n > filelist.dat

# Do batch conversion using sips
i=1
while read p; do

  file=$(sed -n $i"p" filelist.dat | awk {'print $2'})
  name=$(basename $file .$extin)

  echo "File in:" $name"."$extin
  echo "File out:" $name"."$extout

  sips -s format $extout $name"."$extin --out $name"."$extout

i=$((i+1))

done < filelist.dat

rm -rf filelist.dat

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
