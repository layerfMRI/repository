#!/bin/bash
./a.out
echo "Programm ausgeführt, versuche jetzt gnuplot zu starten"
gnuplot "gnuplot.txt"
echo "gnuplot ist fertig, versuche jetzt .ps datei zu zeigen"
#/Applications/Preview.app/Contents/MacOS/Preview "plot.ps" &
evince plot.ps
echo "ganz fertig"
