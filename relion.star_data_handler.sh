#!/bin/bash
#

echo "------------------------------------------------------------------"
echo "$(basename $0)"
echo "------------------------------------------------------------------"
echo "-i - input star file (required)"
echo "-d - Delete column (name)"
echo ""
echo "------------------------------------------------------------------"

flagcheck=0

while getopts ':-i:d:o:' flag; do
  case "${flag}" in
    i) starin=$OPTARG
    flagcheck=0 ;;
    o) starout=$OPTARG
    flagcheck=1 ;;
    d) columndel=$OPTARG
    flagcheck=1 ;;
    \?)
      echo ""
      echo "Invalid option, please read initial program instructions..."
      echo ""
      exit 1 ;;
  esac
done

if [ $flagcheck = 0 ] ; then
  echo ""
  echo "No options used, exiting, I require an input..."
  echo ""
  exit 1
fi

#Get input star file basename
file=$(basename $starin .star)

#Dir out
dirout=.star_data_handler

#Delete column
if [[ -z $columndel ]] ; then
  echo 'No column to delete'
else
  #Split star file into parts
  relion.star_extract_data.sh $starin $dirout
  #Find column number
  columndelno=$(grep $columndel $dirout/.mainDataHeader.dat | awk '{print $2}' | sed 's/#//g')

  if [[ -z $columndelno ]] ; then
    echo ''
    echo 'Column not found, skipping delete option...'
  else
    #Remove column data
    awk -v col=$columndelno '!($col="")' $dirout/.mainDataLines.dat > $dirout/.tmp.dat
    mv $dirout/.tmp.dat $dirout/.mainDataLines.dat
    #Reformat data header - remove header for deleted column and renumber columns
    grep -v $columndel $dirout/.mainDataHeader.dat | grep '_rln' | cut -d "#" -f1 | awk '{print $0,"#"FNR}' > $dirout/.tmp.dat
    #Reformat data header - renumber the header columns
    printf "data_particles\nloop\n" | cat - $dirout/.tmp.dat > $dirout/.mainDataHeader.dat
  fi
fi

if [[ -z $starout ]] ; then
  echo 'No output...'
else
  #Recombine to new star file
  cat $dirout/.version.dat <(echo) $dirout/.opticsDataHeader.dat $dirout/.opticsDataLines.dat <(echo) $dirout/.version.dat <(echo) $dirout/.mainDataHeader.dat $dirout/.mainDataLines.dat > tmp.star
  mv tmp.star $starout
fi

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
