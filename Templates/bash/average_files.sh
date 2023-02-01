#!/bin/bash


echo "fange an"

#https://stackoverflow.com/questions/31645668/average-of-multiple-files-in-shell 

awk '{rows=FNR; cols=NF; for (i = 1; i <= NF; i++) { total[FNR, i] += $i }}
     FILENAME != lastfn { count++; lastfn = FILENAME }
     END { for (i = 1; i <= rows; i++) { 
                for (j =  1; j <= cols; j++) {
                    printf("%s ", total[i, j]/count)
                }
                printf("\n")
            }
        }' *test.txt > ofile.txt

 
