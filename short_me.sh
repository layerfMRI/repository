#!/bin/bash

echo "starting"

3dcalc -a $1 -datum short -gscale -expr 'a' -prefix short_$1 -overwrite

echo "done"
