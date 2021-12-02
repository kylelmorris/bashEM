#!/bin/bash
#

server=$1
dir=$2
dirout=$3
port=$4

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] ; then

  echo ""
  echo "Variables empty, usage is ${0} (1) (2) (3)"
  echo ""
  echo "(1) = server"
  echo "(2) = dirin Relion directory in on server"
  echo "(3) = Local directory to backup to"
  echo "(4) = port number for scp (optional)"
  exit

fi

if [[ -z $3 ]] ; then
  port=22
fi

# Get directory full path
#cwd=$(pwd)
#dirin=$(cd ${dir}; pwd -P) #This is the true path, ignoring symbolic links
#dirname=$(cd ${dir}; pwd) #This is the path including symbolic links
#cd ${cwd}
dirin=$dir
dirname=$dir

# Directory and folder names
ext=$(echo ${dirin##*.})
name=$(basename $dirin .${ext})
dir=$(dirname $dirin)
rlnpath=$(echo $dirname | sed -n -e 's/^.*Relion//p')

#Get last iteration index
iteration=$(ssh $server ls -tr ${dirin}| grep run | grep data | tail -n 1 | sed -e 's/.*run_\(.*\)_data.*/\1/')

#Report what's going to happen
echo ''
echo '#########################################################################'
echo $iteration
echo ''
echo 'Relion directory name to be backed up:'
echo ${dirname}
echo ''
echo 'Relion directory to be backed up (ignoring symbolic links):'
echo ${dirin}
echo ''
echo 'Backup location is:'
echo ${dirout}
echo ''
echo 'The following directory structure will be created:'
echo ${dirout}
echo ''
echo '#########################################################################'
echo ''
echo 'Hit Enter to continue or ctrl-c to quit...'
read p

#Write a README to the backup location with the original location of the files
echo "host information (local):" > $dirout/README
hostname -s >> $dirout/README
echo "host information (remote):" >> $dirout/README
echo $server -s >> $dirout/README
echo "" >> $dirout/README
echo "Relion directory location:" >> $dirout/README
echo $(ls -d -1 $dirout) >> $dirout/README
echo "" >> $dirout/README

#Copy files
rsync -aP $server:"${dirin}/run.err \
${dirin}/run.out \
${dirin}/note.txt \
${dirin}/*${iteration}*" \
${dirout}

#Copy run note details to README
cat $dirout/note.txt >> $dirout/README
mv $dirout/README ${dirout}${rlnpath}

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
