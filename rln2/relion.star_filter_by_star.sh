#!/bin/bash
#

starin=$1
starfiltby=$2
columnfiltby=$3

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]]; then

  echo ""
  echo "Variables empty, usage is relion_star_filter_by_star.sh (1) (2) (3)"
  echo ""
  echo "(1) = star to filter"
  echo "(2) = star to filter by"
  echo "(2) = column to filter by (i.e. rlnImageName)"
  echo ""
  exit

fi

#Useful messages
echo ''
echo 'star to filter:     ' $starin
echo 'star to filter by:  ' $starfiltby
echo 'column to filter by:' $columnfiltby
echo ''

# Clean up
rm -rf *dat

#Get column number
column=$(grep $columnfiltby $starfiltby | awk '{print $2}' | sed 's/#//g')
echo $columnfiltby 'is column number:' $column
echo ''
echo 'Filtering by column #:' $column

#Get data and remove new lines
cat $starfiltby | awk -v c=${column} {'print $c'}  >> columnfiltby.dat
grep -v '^$' columnfiltby.dat > tmp.dat
mv tmp.dat columnfiltby.dat

echo 'Number of particles to extract from:' $starin 'is:' $(wc -l columnfiltby.dat | awk {'print $1'})
echo ''

#Get star file header
awk '{if (NF > 3) exit; print }' < $starin > header.dat

#Filter star file by data that exists in filter by star file
i=1
while [ $i -lt $(wc -l columnfiltby.dat | awk {'print $1'}) ] ; do
  grep $(sed -n ${i}p columnfiltby.dat) $starin >> tmp.dat
  echo -en 'Working on line' $i 'of' $(wc -l columnfiltby.dat | awk {'print $1'}) \\r
  i=$((i+1))
done

cat header.dat tmp.dat > star_filtered.star

#Useful messages
echo 'Number of lines in star used for filtering:' $(wc -l $starfiltby | awk {'print $1'})
echo 'Number of lines in star used now filtered:' $(wc -l star_filtered.star | awk {'print $1'})
echo ''
echo 'Done!'

rm -rf *dat

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
