#!/bin/bash
#
# gnuplot movie creation script
#
# Renzo
#
# creates a set of png files from gnuplot,
# and encodes them with mplayer.
#
# REQUIREMENTS:
# mplayer, possibly libmp3lame if it bitches about encoding
# run this program from the bash shell
#
#
#
echo "running gnuplot

"
count=1000;
for ((inc = 450; inc >= 1; inc = inc - 1)); 
do
count=`expr $count + 1`;
echo "
set yrange [-1:1]; 
set isosample 100,100; 
set title '$inc degrees rotation'; 
set terminal png small ;
set output '$count.png';
plot cos(x+($inc)/10.)" | gnuplot;
done

#
# Convert png to jpg
#
#echo "converting png images to jpg
#
#"
#for i in `ls -1| grep png`;
#do
#convert $i $i.jpg;
#done

#
# create movie (divx4) at 4 FPS
#
echo "creating movie output.avi out of the png files

"

mencoder "mf://*.png" -mf type=png:fps=18 -ovc lavc -o output.avi

for i in `ls -1| grep png`;
do
rm $i
done

#
# clean up extra files
#
#rm -Rf *.png *.jpg
