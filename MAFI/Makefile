CXX=g++
CXXFLAGS=-g3 -O3 -msse3
LDLIBS= -ltjutils -lodindata -lodinpara -lodinseq -lblitz -lgsl -lgslcblas
PROGS= MAFI_COMPLEX 
  

all: $(PROGS)
MAFI_COMPLEX:utils.o

clean:
	rm -f $(PROGS)
