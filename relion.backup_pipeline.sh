#!/bin/bash
#

local=$1
remote=$2
port=$3

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is ${0} (1) (2) (3)"
  echo ""
  echo "(1) = local Relion directory in"
  echo "(2) = remote Relion directory to backup to"
  echo "(3) = port number for scp (optional)"
  exit

fi

if [[ -z $3 ]] ; then
  port=22
fi

#Copy files
echo "rsync -aP --rsh='ssh -p ${port}' \
${local}/.gui* \
${local}/.Nodes \
${remote}" > backup.com

bash backup.com

echo ""
echo "Copied all gui settings, default_pipeline.star and .Nodes"

rm -rf backup.com

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
