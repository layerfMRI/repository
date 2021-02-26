
Spalten = 160
Spalte = 1

set xrange [0:600];
set yrange [-1:3];

plot 'Ez.dat' matrix using 1:3 every 1:999:1:(Spalte-1) with lines , 'K.dat'

load 'schritt.gnuplot'



