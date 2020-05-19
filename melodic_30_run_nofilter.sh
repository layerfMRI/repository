#!/bin/bash

#This does the drift correction and a subsequence melodic into 30 ICs

melodic -i $1 --nomask --nobet -d 30
