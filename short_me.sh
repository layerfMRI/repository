#!/bin/bash

echo "starting"

3dcalc -a $1 -datum short -gscale -expr 'a' -prefix $1 -overwrite

echo "done"
