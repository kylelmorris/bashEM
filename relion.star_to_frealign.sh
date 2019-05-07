#!/bin/csh -f

## Written by Axel Brilot UCSF
## Converts Relion star file to Frealign version 9 parameter file
## Converts a relion star file to a frealign parameter file.
## Further uses relion and imod functions to generate a stack to go with the parameter file

set MakeStack = 1

set starfile = $1
set parfile = $2
set pixelSize = $3

if ($1 == "" || $2 == "" || $3 == "" ) then
  echo ""
  echo -n "Input Relion star file?"
  echo ""
  set starfile = $<
  echo $starfile
  echo ""
  echo -n "Output Frealign par file?"
  echo ""
  set parfile = $<
  echo $parfile
  echo ""
  echo -n "Pixel size of images in star file?"
  echo ""
  set pixelSize = $<
  echo $pixelSize
endif

set imagename = `grep _rlnImageName  $starfile | awk -F\# '{print $2}'`

set psi = `grep _rlnAnglePsi $starfile | awk -F\# '{print $2}'`
if ($psi == "") set psi = 0
set theta = `grep _rlnAngleTilt $starfile | awk -F\# '{print $2}'`
if ($theta == "") set theta = 0
set phi = `grep _rlnAngleRot $starfile | awk -F\# '{print $2}'`
if ($phi == "") set phi = 0
set y = `grep _rlnOriginY $starfile | awk -F\# '{print $2}'`
if ($y == "") set y = 0
set x = `grep _rlnOriginX $starfile | awk -F\# '{print $2}'`
if ($x == "") set x = 0
set mag = `grep "_rlnMagnification " $starfile | awk -F\# '{print $2}'`
if ($mag == "") then
  echo ""
  echo -n "Magnification at the detector?"
  echo ""
  set m = $<
  echo $m
endif
set image = `grep "_rlnGroupNumber " $starfile | awk -F\# '{print $2}'`
if ($image == "") set image = 0
set df1 = `grep "_rlnDefocusU " $starfile | awk -F\# '{print $2}'`
if ($df1 == "") then
  echo "ERROR: no defocus1 values found in star file."
  exit
endif
set df2 = `grep "_rlnDefocusV " $starfile | awk -F\# '{print $2}'`
if ($df1 == "") then
  echo "ERROR: no defocus2 values found in star file."
  exit
endif
set dang = `grep "_rlnDefocusAngle " $starfile | awk -F\# '{print $2}'`
if ($dang == "") then
  echo "ERROR: no astigmatic angle values found in star file."
  exit
endif

awk 'NF <=2 ' ${starfile} > ${starfile:t:r}_sort.star 
grep "@" $starfile | awk '{print $'$imagename'"@",$0}' | awk 'BEGIN{FS = "@"} {print $2, $1, $0}' | sort | cut -d " " -f 4- >> ${starfile:t:r}_sort.star



if ($mag == "") then
  grep "@" ${starfile:t:r}_sort.star | awk '{printf "%7d%8.2f%8.2f%8.2f%8.2f%8.2f%8d%6d%9.1f%9.1f%8.2f%7.2f\n",NR,$'$psi',$'$theta',$'$phi',-$'$x',-$'$y','$m',$'$image',$'$df1',$'$df2',$'$dang',0.0 }' > $parfile
else
  grep "@" ${starfile:t:r}_sort.star | awk '{printf "%7d%8.2f%8.2f%8.2f%8.2f%8.2f%8d%6d%9.1f%9.1f%8.2f%7.2f\n",NR,$'$psi',$'$theta',$'$phi',-$'$x',-$'$y',$'$mag',$'$image',$'$df1',$'$df2',$'$dang',0.0 }' > $parfile
endif
#
echo ""

grep -v C $parfile | awk -v pixelSize=$pixelSize '{printf "%7d%8.2f%8.2f%8.2f%10.2f%10.2f%8d%6d%9.1f%9.1f%8.2f%8.2f%10d%11.2f%8.2f%8.2f\n",FNR,$2,$3,$4,$5*pixelSize,$6*pixelSize,$7,$8,$9,$10,$11,100,0,5000,60,0}' > ${parfile:t:r}_v9.par


if ( $MakeStack == 0 ) then
	echo Not making Stack, now done with conversion.
	goto done
endif


set wordCount = `wc -l ${starfile:t:r}_sort.star | awk '{print $1}'`

echo Now making stack


set i = 1
set tailCount = 10000
while ( $i <= $wordCount ) 
    if ( $i == 1 ) then
	##awk 'NF <=1' ${starfile:t:r}_sort.star > ${starfile:t:r}_1_10000.star
	##echo -n _rlnImageName \#1 >> ${starfile:t:r}_1_10000.star
	##echo "" >> ${starfile:t:r}_1_10000.star
	head -10000 ${starfile:t:r}_sort.star | sed 's|particles_down6.mrcs|particles.mrcs|g' > ${starfile:t:r}_1_10000.star
	##relion_stack_create --i ${starfile:t:r}_1_10000.star --o ${starfile:t:r}_1_10000
	relion_stack_create --i ${starfile:t:r}_1_10000.star --o ${starfile:t:r}
	mv ${starfile:t:r}.mrcs ${starfile:t:r}.mrc
	@ i = $i + 10000
    else
       @ endLine =  $i + $tailCount - 1
       if ( $wordCount < $endLine ) then
	    set endLine = $wordCount
	    @ tailCount = $wordCount % $tailCount
       endif 
       ##echo -n _rlnImageName \#1 > ${starfile:t:r}_${i}_${endLine}.star
       awk 'NF <=2 ' ${starfile:t:r}_sort.star > ${starfile:t:r}_${i}_${endLine}.star 
       head -${endLine} ${starfile:t:r}_sort.star | sed 's|particles_down6.mrcs|particles.mrcs|g' | tail -$tailCount >> ${starfile:t:r}_${i}_${endLine}.star 
       relion_stack_create --i ${starfile:t:r}_${i}_${endLine}.star --o ${starfile:t:r}_${i}_${endLine}
	mv ${starfile:t:r}_${i}_${endLine}.mrcs ${starfile:t:r}_${i}_${endLine}.mrc
	addtostack << EOF
${starfile:t:r}.mrc
0
1
${starfile:t:r}_${i}_${endLine}.mrc
EOF
	@ i = $i + 10000
    endif
end

echo Done making stack. Conversion finished.

done:
