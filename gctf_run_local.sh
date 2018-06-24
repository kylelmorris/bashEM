#!/usr/bin/env bash
#

#Written by Kyle Morris, University of California Berkeley 2018

# Define a timestamp function
timestamp() {
  date +"%T"
}
time=$(timestamp)

start=$1
end=$2
gpu=$3

echo "Make sure you specific a lower and upper range that you want to process..."
echo "gctf_run_local.sh (1) (2) (3)"
echo "gctf_run_local.sh $start $end $gpu"
echo "Will process micrographs $start to $end on gpu $gpu"
echo "Continue? Enter or ctrl-c"
read p

#Link files
ln -sf ../gauto/*automatch.star .
ln -sf ../focus/*noDW.mrc .

#Clean up unwanted
rm -rf 18Jun21_MsGC-apo-BS3-pos9_00*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_01*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_02*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_03*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_04*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_05*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_060*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_061*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_062*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_063*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_064*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_065*_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_0660_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_0661_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_0662_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_0663_noDW*
rm -rf 18Jun21_MsGC-apo-BS3-pos9_0664_noDW*

#Make unique filelist for the execution of script
#ls \*\{${start}..${end}\}\*.mrc > .filelist_${time}.dat
echo "" > .filelist_${time}.dat
i=${start}
while [ $i -le ${end} ]
do
  j=$(printf "%04d\n" $i)
  echo *$j*.mrc >> .filelist_${time}.dat
  i=$((i+1))
done
sed -i '/\*/d' .filelist_${time}.dat

#Run gctf per micrograph since local only seems to work this way
while read file; do
  name=$(sed -n "$i"p filelist_${time}.dat | awk {'print $2'})
  gctf-v1.06 --apix 1.159 --kV 200 --cs 2.6 --ac 0.1 --do_EPA --do_validation --do_unfinished --do_local_refine --boxsuffix _automatch.star --gid $gpu $file
done < .filelist_${time}.dat

rm -rf .filelist_${time}.dat
