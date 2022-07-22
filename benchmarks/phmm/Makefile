CC      = gcc
#CC		= icpc
ARCH_FLAGS=	-msse4.1

GKLPATH= ../../tools/GKL

uname_arch := $(shell uname -m)

SIMDE_ARCH_FLAGS=-D__SSE2__=1 -D__AVX__=1 -D__SSE4_1__=1
SIMDE_INCLUDES=-I$(GKLPATH)/simde



ifeq ($(arch),sse41)
	ARCH_FLAGS=-msse4.1
else ifeq ($(arch),avx2)
	ifeq ($(CXX), icpc)
		ARCH_FLAGS=-march=core-avx2 #-xCORE-AVX2
	else	
		ARCH_FLAGS=-mavx2
	endif
else ifeq ($(arch),avx512)
	ifeq ($(CXX), icpc)
		ARCH_FLAGS=-xCORE-AVX512
	else	
		ARCH_FLAGS=-mavx512bw
	endif
else ifeq ($(arch),native)
        ifeq ($(uname_arch),aarch64)
                ARCH_FLAGS=-march=native $(SIMDE_ARCH_FLAGS)
                INCLUDES+= $(SIMDE_INCLUDES)
        else
                ARCH_FLAGS=-march=native
        endif
else ifneq ($(arch),)
# To provide a different architecture flag like -march=core-avx2 or  -march=armv8.2-a
        ifeq ($(uname_arch),aarch64)
                ARCH_FLAGS=-march=$(arch) $(SIMDE_ARCH_FLAGS)
                INCLUDES+= $(SIMDE_INCLUDES)
        else
		ARCH_FLAGS=-march=$(arch)
	endif
else
        ifeq ($(uname_arch),aarch64)
                ARCH_FLAGS=$(SIMDE_ARCH_FLAGS)
                INCLUDES+= $(SIMDE_INCLUDES)
endif
endif
CFLAGS= -g -O2 -std=c++11 $(ARCH_FLAGS)

#VTUNE_HOME= /opt/intel/vtune_profiler
INC=
SHARED_LIBRARIES = -fopenmp -L$(GKLPATH)/build/native -lgkl_pairhmm_omp -lstdc++ -ldl

ifneq ($(VTUNE_HOME),)
CFLAGS+= -DVTUNE_ANALYSIS=1
INC+= -I${VTUNE_HOME}/include 
SHARED_LIBRARIES+= -L${VTUNE_HOME}/lib64 -littnotify

endif
INC+=$(INCLUDES)

all: phmm

phmm: PairHMMUnitTest.o
	$(CC) -o $@ $^ $(CFLAGS) ${INC} $(SHARED_LIBRARIES)

PairHMMUnitTest.o: PairHMMUnitTest.cpp PairHMMUnitTest.h
	$(CC) -c $(CFLAGS) $(INC) -fopenmp $<

.PHONY: clean

clean:
	rm -f phmm *.o
