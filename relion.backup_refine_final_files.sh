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
  echo "(2) = Backup directory out"
  echo "(3) = port number for scp (optional)"
  exit

fi

if [[ -z $3 ]] ; then
  port=22
fi

# Directory and folder names
ext=$(echo ${dirin##*.})
name=$(basename $dirin .${ext})
dir=$(dirname $dirin)
rlnpath=$(echo $dirin | sed -n -e 's/^.*Relion//p')

#Report what's going to happen
echo ''
echo '#########################################################################'
echo ''
echo 'Refine3D directory to be backed up:'
echo ${dirin}
echo ''
echo 'Backup location is:'
echo ${dirout}
echo ''
echo 'The following directory structure will be created:'
echo ${dirout}/Relion${rlnpath}
echo ''
echo '#########################################################################'
echo ''
echo 'Hit Enter to continue or ctrl-c to quit...'
read p

#Write a README to the backup location with the original location of the files
echo "host information:" > $dirin/README
hostname -s >> $dirin/README
echo "" >> $dirin/README
echo "Refine3D location:" >> $dirin/README
echo $(ls -d -1 $dirin) >> $dirin/README
echo "" >> $dirin/README
cat $dirin/note.txt >> $dirin/README

#Set up directory on remote end
mkdir -p ${dirout}/Relion${rlnpath}

#Copy files from specified Refine3D directory to backup location
#rsync -aP --rsh=\'ssh -p ${port}\' $dirin/run.job \
scp -P $port -r $dirin/run.job \
$dirin/run_model.star \
$dirin/run.out \
$dirin/run_sampling.star \
$dirin/run_class001_angdist.bild \
$dirin/run_class001.mrc \
$dirin/run_data.star \
$dirin/run.err \
$dirin/run_half1_class001_unfil.mrc \
$dirin/run_half2_class001_unfil.mrc \
$dirin/*pipeline* \
$dirin/note.txt \
$dirin/README \
${dirout}/Relion/${rlnpath}

rm -rf $dirin/README

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
