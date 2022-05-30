#!/bin/bash
#Sequential file processing script

source /mount/local/app/EMAN2/eman2.bashrc

ext="mrcs"
suffix="_float"

#Remove existing converted micrographs from filelist.dat, excluding those with the set suffix i.e. already processed
ls -n *.$ext | grep -v $suffix | awk {'print $9'} | cat -n > filelist.dat

#Loop through filelist.dat for all the files
i=1
while read p; do
   file=$(sed -n $i"p" filelist.dat | awk {'print $2'})
   name=$(basename $file .$ext)

   orig="$name".$ext
   new="$name""$suffix".$ext

   if [ -e $new ]; then
    echo ""
    echo $new "- File exists, skipping"
    echo ""
   else
    echo ""
    echo "File_in:" $orig
    echo "File_out:" $new
    echo ""
    e2proc2d.py --outmode=float $orig $new
   fi

   i=$((i+1))
done < filelist.dat

#rm filelist.dat

echo "//////////////////////"
echo "File processing complete"
echo "//////////////////////"

ls

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
