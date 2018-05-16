#!/bin/bash
#

dirin=$1
dirout=$2
port=$3

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is ${0} (1) (2)"
  echo ""
  echo "(1) = Refine3D directory in"
  echo "(2) = rsync backup directory out"
  echo "(3) = port number for scp (optional)"
  exit

fi

if [[ -z $3 ]] ; then
  port=22
fi

#Write a README to the backup location with the original location of the files
echo "host information:" > $dirout/README
hostname -s >> $dirout/README
hostname -I >> $dirout/README
echo "" >> $dirout/README
echo "Refine3D location" >> $dirout/README
echo $(ls -d -1 $PWD/$dirin) >> $dirout/README
echo "" >> $dirout/README
cat $dirin/note.txt >> $dirout/README

#Copy files from specified Refine3D directory to backup location
scp -P $port -r $dirin/run.job $dirout
scp -P $port -r $dirin/run_model.star $dirout
scp -P $port -r $dirin/run.out $dirout
scp -P $port -r $dirin/run_sampling.star $dirout
scp -P $port -r $dirin/run_class001_angdist.bild $dirout
scp -P $port -r $dirin/run_class001.mrc $dirout
scp -P $port -r $dirin/run_data.star $dirout
scp -P $port -r $dirin/run.err $dirout
scp -P $port -r $dirin/run_half1_class001_unfil.mrc $dirout
scp -P $port -r $dirin/run_half2_class001_unfil.mrc $dirout
scp -P $port -r $dirin/*pipeline* $dirout
scp -P $port -r $dirin/note.txt $dirout
