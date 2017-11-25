CXX=g++
CXXFLAGS=-g3 -O3 -msse3 -I/NOBACKUP/odin/include
LDLIBS = -ltjutils -lodindata -lodinpara -lodinseq -lblitz -lgsl -lgslcblas 
LDFLAGS = -L/NOBACKUP/odin/lib/ -Wl,-rpath,/NOBACKUP/odin/lib
PROGS= INTERPOL
 

all: $(PROGS)




clean:
	rm -f $(PROGS)
