#!/bin/bash
#

local=$1
remote=$2
port=$3

if [[ -z $1 ]] || [[ -z $2 ]] ; then

  echo ""
  echo "Variables empty, usage is ${0} (1) (2) (3)"
  echo ""
  echo "(1) = local Refine3D directory in"
  echo "(2) = remote Refine3D directory to backup to"
  echo "(3) = port number for scp (optional)"
  exit

fi

if [[ -z $3 ]] ; then
  port=22
fi

#Get last iteration index
iteration=$(ls ${local} | grep run_it | tail -n 1 | cut -c5-9)

#Copy files
scp -P $port -r ${local}/run.err \
${local}/run.out \
${local}/*.star \
${local}/note.txt \
${local}/*${iteration}* \
${remote}

echo ""
echo "Copied run.out, run.err, note.txt, *.star and final iteration finals"
# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
