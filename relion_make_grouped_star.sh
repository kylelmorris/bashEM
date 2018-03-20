#!/bin/bash
#
## Adapted by Kyle Morris, University of Warwick 2015
## From csh source code at: http://www2.mrc-lmb.cam.ac.uk/relion/index.php/Make_grouped_star.csh
#

split_file=$1
input_star=$2
output_star=$3

if [ $# -lt 3 ]; then
 echo "Usage: " $0 " splitfile particles.star particles_grouped.star "
else
 # make the groups.dat file: col1=micrographname, col2= groupname
 cat $split_file | awk 'BEGIN {igroup=1} {if ($NF<1) {igroup++} else {print $1, "group_"igroup} }' >groups.dat

 # make the header
 awk 'BEGIN {i=1} {if (NF<3) {print $0; if ($1~"_rln") i++; } else {exit} } END {print "_rlnGroupName #"i}' < $input_star > $output_star

 # How many lines are there in the header?
 nhead=$(wc -l $output_star | awk '{print $1}')

 # check in which column _rlnMicrographName is stored
 colno=$(grep _rlnMicrographName $input_star | awk -F"#" '{print $2}')

 # change all lines in the input starfile to have the corresponding groupname added to it
 ll=0
 nl=$(wc -l groups.dat | awk '{print $1}')
 ntot=0
 ngroup=0
 oldgroupname=$(head -1 groups.dat|awk '{print $2}')

 while [ $ll -lt $nl ]; do
   ll=$((ll+1))
   line=$(head -n $ll groups.dat | tail -1)
   #echo "line: "$line

   # for each group print the number of particles in it
   line1=$(head -n $ll groups.dat | tail -1 | awk {'print $1'})
   line2=$(head -n $ll groups.dat | tail -1 | awk {'print $2'})

   if [[ $oldgroupname != $line2 && $ll -gt 2 ]]; then
     echo $oldgroupname" has " $ngroup " particles; total number of particles= " $ntot
     ngroup=0
     oldgroupname=$line2
   fi

   # edit the lines of the output starfile: add groupname at the end of it
   cat $input_star | awk -v micname=$line1 -v grname=$line2 -v colno=${colno} '{if (NF>2) { if ($colno==micname) print $0,grname}  }' >> $output_star

   # keep track of total number of particles and number of particles in this group
   ncurr=$(wc -l $output_star | awk -v nhead=$nhead '{print $1 - nhead}')
   tmp=$((ncurr-ntot))
   ngroup=$((ngroup+tmp))
   ntot=$ncurr

   # report percentage complete
   outlines=$(wc -l $output_star | awk '{print $1}')
   inlines=$(wc -l $input_star | awk '{print $1}')

   pcnt=$(bc <<< "scale=3; $outlines/$inlines*100")
   echo "Completed ${pcnt}%, ${outlines} of $inlines"
   echo -en "\e[1A"

 done
echo $oldgroupname" has " $ngroup " particles; total number of particles= " $ntot
rm -rf groups.dat
fi
