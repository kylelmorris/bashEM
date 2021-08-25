#!/bin/bash
#

#this script is intended for extraction of sub ptcls from signal subtracted boxes created by projection_subtraction.py by Daniel and Eugene at UCSF

echo 'Note: In the current implementation this script will overwrite you existing boxes.'
echo 'Be careful!'

#input variables
star=$1
box=$2
newbox=$3

## Check inputs
if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] ; then
  echo ""
  echo "Variables empty, check inputs"
  echo ""
  echo "(1) = Input star file (*.star)"
  echo "(2) = Input box size (px)"
  echo "(3) = Extraction box size (px)"
  echo ""
  exit
fi

#calculate
ptclradius=$((${newbox}/200*75))

#get star header
awk '{if (NF > 3) exit; print }' < $star > header.star

#get particle lines
diff header.star ${star} | awk '!($1="")' > ptcllines.star
sed '1d' ptcllines.star > tmp.dat
mv tmp.dat data.star

#get column numbers from header
OriginX=$(grep rlnOriginX header.star | awk {'print $2'}) #ptcl shifts
OriginY=$(grep rlnOriginY header.star | awk {'print $2'}) #ptcl shifts
CoordinateX=$(grep rlnCoordinateX header.star | awk {'print $2'}) #ptcl coords
CoordinateY=$(grep rlnCoordinateY header.star | awk {'print $2'}) #ptcl coords
Imagename=$(grep rlnImageName header.star | awk {'print $2'}) #ptcl name
Micname=$(grep rlnMicrographName header.star | awk {'print $2'}) #mic name
#parse out #
OriginX=$(echo "${OriginX//#}")
OriginY=$(echo "${OriginY//#}")
CoordinateX=$(echo "${CoordinateX//#}")
CoordinateY=$(echo "${CoordinateY//#}")
Imagename=$(echo "${Imagename//#}")
Micname=$(echo "${Micname//#}")

#edit coordinate x and y to reflect new ptcl shifts
awk -v var1=${OriginX} -v var2=$((${box}/2)) -v var3=${CoordinateX} {'$var3=var2+$var1; print'} data.star > dataedit.star        #coordinatex
awk -v var1=${OriginY} -v var2=$((${box}/2)) -v var3=${CoordinateY} {'$var3=var2-$var1; print'} dataedit.star > dataedit2.star   #coordinatey
mv dataedit2.star dataedit.star

#reset originX and originY to 0 now that boxes are recentred to be extracted
awk -v var1=${OriginX} -v var2=${OriginY} {'$var1=0; $var2=0; print'} dataedit.star > dataedit2.star
mv dataedit2.star dataedit.star

#switch ptcl image name into micrograph name for sub ptcl extraction
awk -v var1=$Imagename -v var2=$Micname {'$var2=$var1; print'} dataedit.star | sed 's/000001@//' > dataedit2.star
#sed 's/.*@//' #If you need to remove the ptcl number preceeding @ character
mv dataedit2.star dataedit.star

#make new star file
cat header.star dataedit.star > newstar.star

#use relion to extract new sub particles from signal subtracted boxes
mkdir Subtraction_boxed
relion_preprocess --i newstar.star --reextract_data_star newstar.star --part_dir Subtraction_boxed --list_star Projection_subtracted_particles.star --extract --extract_size ${newbox} --norm --bg_radius ${ptclradius}

#tidy up
rm -rf data.star
rm -rf header.star
rm -rf dataedit.star
rm -rf ptcllines.star
#name=$(echo "${star//.star}") #parse out .star extension
mv newstar.star $name"_centre_focus.star"

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
