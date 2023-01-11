#!/bin/bash


echo "starting"


for idx in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 ; do
  3dcalc -a $1'['`expr $idx`'..$(32)]' -prefix ${idx}_$1 -expr 'a'
done

echo "and buy"

 
