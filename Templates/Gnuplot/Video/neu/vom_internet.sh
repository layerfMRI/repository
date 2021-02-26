 
#!/bin/bash
#
# gnuplot movie creation script
#
# Eric Thern
# June 30, 2003
#
#
# creates a set of png files from gnuplot,
# converts them to .jpg files and encodes them with mplayer.
#
# REQUIREMENTS:
# mplayer, possibly libmp3lame if it bitches about encoding
# convert (jpg, gd and png libraries as well, should come with standard dists though)
# gnuplot
# run this program from the bash shell
#
#
# developed on redhat linux 9, should have no problems working anywhere though.
#

#
# run GNUPlot
#
echo "running gnuplot

"
count=1000;
for ((theta = 0; theta <= 360; theta = theta + 1)); 
do
count=`expr $count + 1`;
echo "set parametric; 
set angle degree; 
set urange [0:360]; 
set vrange [0:360]; 
set isosample 36,36; 
set ticslevel 0; 
set size 1.0,1.0; 
a = 1; 
set view 60, $theta; 
set title '$theta degrees rotation'; 
set terminal png small ;
set output '$count.png';
splot a*cos(u)+($count/1000)*cos(v),a*sin(u)*cos(v),a*sin(v)" | gnuplot;
done

#
# Convert png to jpg
#
echo "converting png images to jpg

"
#for i in `ls -1| grep png`;
#do
#convert $i $i.jpg;
#done

#
# create movie (divx4) at 4 FPS
#
echo "creating movie $1.avi out of the png files

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
