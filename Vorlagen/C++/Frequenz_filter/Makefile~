# FIR filter class, by Mike Perkins
# 
# a simple C++ class for linear phase FIR filtering
#
# For background, see the post http://www.cardinalpeak.com/blog?p=1841
#
# Copyright (c) 2013, Cardinal Peak, LLC.  http://www.cardinalpeak.com
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
# 1) Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 
# 2) Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials provided
#    with the distribution.
# 
# 3) Neither the name of Cardinal Peak nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# CARDINAL PEAK, LLC BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
# USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
# Note that this makefile must end in
# a carriage return, and "command" lines must begin with a
# tab character

APPNAME = devel
SRC = devel.cpp filt.cpp

#############################
# Edit the lines below if any special libraries need to be linked
# or include directories need to be searched
############################

INCLUDES = -I.

LIBS = -lm

#############################
# Should not need to edit anything below here under normal circumstances
############################

# the C++ compiler we are using, and our preferred flags
CPP = g++
CPPFLAGS = -O3 $(INCLUDES)

#How to build a .o file from a .cpp file
.cpp.o:
	$(CPP) $(CPPFLAGS) -c $<

#How to build a .o file from a .cc file
.cc.o:
	$(CPP) $(CPPFLAGS) -c $<

#How to build a .o file from a .c file
.c.o:
	$(CPP) $(CPPFLAGS) -c $<

# Strip off the .cc, .c, and .cpp suffixes for all files in SRC and replace 
# them with .o.  These object files are our dependencies for building the
# target
OBJ = $(addsuffix .o, $(basename $(SRC)))

# The target APPNAME depends on the OBJ files
$(APPNAME): $(OBJ)
	$(CPP) $(CPPFLAGS) -o $@ $(OBJ) $(LIBS)

# clean up by removing .o files and the executable
# ***the "rm" lines below must be preceded by a TAB****
clean:
	rm -f $(OBJ) $(APPNAME).exe Makefile.am

# executing this target will add .h dependencies on the end of this
# file.  NOTE: this doesn't work on windows under mingw, msys
depend:
	makedepend $(CPPFLAGS) -Y $(SRC)
