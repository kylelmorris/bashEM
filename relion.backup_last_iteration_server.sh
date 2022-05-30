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

if [[ -z $4 ]] ; then
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
rlnpath=$(echo $dirname | sed -n -e 's/^.*Relion//pI' | cut -d'/' -f2-)

#Get last iteration index
iteration=$(ssh $server ls -tr ${dirin}| grep run | grep data | tail -n 1 | sed -e 's/.*run_\(.*\)_data.*/\1/')

#Set up directory on local end
mkdir -p ${dirout}/${rlnpath}

##Write a README to the backup location with the original location of the files
# Remote host
echo "host information (remote):" > ${dirout}/${rlnpath}/README
echo $server -s >> ${dirout}/${rlnpath}/README
echo "" >> ${dirout}/${rlnpath}/README
# Remote host directory, use this to get true path
echo "Relion directory location (on server):" >> ${dirout}/${rlnpath}/README
dirbackup=$(ssh $server readlink -f $dirin)
echo $dirbackup >> ${dirout}/${rlnpath}/README
echo "" >> ${dirout}/${rlnpath}/README
#Local host
echo "host information (local):" >> ${dirout}/${rlnpath}/README
hostname -s >> ${dirout}/${rlnpath}/README
echo "" >> ${dirout}/${rlnpath}/README
# Local directory
echo "Relion directory location (local):" >> ${dirout}/${rlnpath}/README
echo ${dirout} >> ${dirout}/${rlnpath}/README
echo "" >> ${dirout}/${rlnpath}/README
# Remote directory name
echo "Relion directory name (local):" >> ${dirout}/${rlnpath}/README
echo ${rlnpath} >> ${dirout}/${rlnpath}/README
echo "" >> ${dirout}/${rlnpath}/README

#Report what's going to happen
echo ''
echo '#########################################################################'
echo 'Iteration to be backed up:'
echo $iteration
echo ''
echo 'Relion directory name to be backed up:'
echo ${rlnpath}
echo ''
echo 'Relion directory to be backed up (ignoring symbolic links):'
echo ${dirbackup}
echo ''
echo 'Backup location to (local):'
echo ${dirout}
echo ''
echo 'The following directory structure will be created:'
echo ${rlnpath}
echo ''
echo '#########################################################################'
echo ''
echo 'Hit Enter to continue or ctrl-c to quit...'
read p

#Copy files
rsync -aP $server:"${dirin}/run.err \
${dirin}/run.out \
${dirin}/note.txt \
${dirin}/*${iteration}*" \
${dirout}/${rlnpath}

#Copy run note details to README
cat ${dirout}/${rlnpath}/note.txt >> ${dirout}/${rlnpath}/README

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
