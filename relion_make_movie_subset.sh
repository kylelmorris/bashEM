
#!/bin/bash
#

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] ; then

 echo '================================================================================================================='
 echo 'Usage:' $0 ' run1_data.star particles_movie.star particles_movie_subset.star'
 echo ''
 echo 'Where run1_data.star is a selection of an originally larger data set of the averaged particles.'
 echo ''
 echo 'The input particles_movie.star contains the movie frames of the entire larger data set.'
 echo ''
 echo 'The output particles_movie_subset.star will contain the movie frames only for those particles in run1_data.star.'
 echo ''
 echo 'Using particles_movie_subset.star in a continuation of run1 will speed up the expansion of the movie frames.'
 echo '================================================================================================================='

else

 star_selected_particles=$1
 star_all_movies_frame=$2
 star_selected_movie_frames=$3

 echo ''
 echo 'Star file containing selected particles:' $star_selected_particles
 echo ''
 echo 'Star file containing all extracted movie frame particles:' $star_all_movies_frame
 echo ''
 echo 'Output movie subset:' $star_selected_movie_frames
 echo ''
 echo '==============================================================='
 echo ''
 echo 'Running'
 echo ''

 # Gets the header of the movie star file
 awk '{if (NF > 3) exit; print }' < ${star_all_movies_frame} > ${star_selected_movie_frames}

 # Gets the name of the micrographs found in the particle star file
 relion_star_printtable ${star_selected_particles} data_ rlnMicrographName | sort | uniq | sed 's|.mrc||' > mics.dat
 # Gets the names of the particles found in the particle star file
 relion_star_printtable ${star_selected_particles} data_ rlnImageName > parts.dat

 # For each line of cat do some grepping
 # Then within this loop do some grepping for every line of particles files

 # Get number of micrographs
 micno=$(cat mics.dat | wc -l)
 echo 'Micrographs to process:' $micno
 echo ''

 # Loop through micrographs
 i=1
 while [ $i -le $micno ]; do

  ##THE FOLLOWING LOOPS THROUGH PRINTING EACH MICROGRAPH USED IN THE PARTICLE STAR FILE
  #mic=$(sed -n ''$i'p' mics.dat)
  #echo -ne "Processing micrograph no:" $i "of" $micno":" $mic
  #grep $mic $star_all_movies_frame >> $star_selected_movie_frames

  ##THE FOLLOWING LOOPS THROUGH THE PARTICLES OF EACH MICROGRAPH AS WELL
  # Get micograph file name from line $i in star file
  mics_part=$(sed -n ''$i'p' mics.dat)
  # Get particle file names and numbers from current micrograph being processed
   grep $mics_part parts.dat > parts_mic.dat
  # Get number of particles for current micrograph
   partno=$(more parts_mic.dat | wc -l)

  j=1
  while [ $j -le $partno ]; do
   echo -ne "Processing micrograph no:" $i "of" $micno": Ptcl no:" $j "of" $partno""\\r
   particle=$(sed -n ''$j'p' parts_mic.dat)
   grep $particle $star_all_movies_frame >> $star_selected_movie_frames
   j=$((j+1))
  done

 i=$((i+1))

 done

echo  ''
echo 'Tidying up...'
rm -rf mics.dat
rm -rf mics_part.dat
rm -rf parts.dat
rm -rf parts_mic.dat
echo 'Done'
echo ''
echo 'Saved new star file containing subset movie particles in:' $star_selected_movie_frames
echo ''

fi
