##/*************************************************************************************
##                           The MIT License
##
##   BWA-MEM2  (Sequence alignment using Burrows-Wheeler Transform),
##   Copyright (C) 2019  Vasimuddin Md, Sanchit Misra, Intel Corporation, Heng Li.
##
##   Permission is hereby granted, free of charge, to any person obtaining
##   a copy of this software and associated documentation files (the
##   "Software"), to deal in the Software without restriction, including
##   without limitation the rights to use, copy, modify, merge, publish,
##   distribute, sublicense, and/or sell copies of the Software, and to
##   permit persons to whom the Software is furnished to do so, subject to
##   the following conditions:
##
##   The above copyright notice and this permission notice shall be
##   included in all copies or substantial portions of the Software.
##
##   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
##   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
##   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
##   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
##   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
##   ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
##   CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##   SOFTWARE.
##
##Contacts: Vasimuddin Md <vasimuddin.md@intel.com>; Sanchit Misra <sanchit.misra@intel.com>;
##                                Heng Li <hli@jimmy.harvard.edu> 
##*****************************************************************************************/


EXE=		bsw
CXX=		g++
#CXX=		icpc

ARCH_FLAGS=	-msse4.1

uname_arch := $(shell uname -m)

SSE2NEON_FLAGS=-D__SSE2__=1 -D__AVX__=1 -D__SSE4_1__=1
SSE2NEON_INCLUDES=-Iext/sse2neon

BWAMEM2_PATH=../../tools/bwa-mem2
INCLUDES=

ifeq ($(arch),sse41)
	ifeq ($(CXX), icpc)
		ARCH_FLAGS=-msse4.1
	else
		ARCH_FLAGS=-msse -msse2 -msse3 -mssse3 -msse4.1
	endif
else ifeq ($(arch),sse42)
	ifeq ($(CXX), icpc)	
		ARCH_FLAGS=-msse4.2
	else
		ARCH_FLAGS=-msse -msse2 -msse3 -mssse3 -msse4.1 -msse4.2
	endif
else ifeq ($(arch),avx)
	ifeq ($(CXX), icpc)
		ARCH_FLAGS=-mavx ##-xAVX
	else	
		ARCH_FLAGS=-mavx
	endif
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
                ARCH_FLAGS=-march=native $(SSE2NEON_FLAGS)
                INCLUDES+= $(SSE2NEON_INCLUDES)
        else
                ARCH_FLAGS=-march=native
        endif
else ifneq ($(arch),)
# To provide a different architecture flag like -march=core-avx2 or  -march=armv8.2-a
        ifeq ($(uname_arch),aarch64)
                ARCH_FLAGS=-march=$(arch) $(SSE2NEON_FLAGS)
                INCLUDES+= $(SSE2NEON_INCLUDES)
        else
		ARCH_FLAGS=-march=$(arch)
	endif
else
        ifeq ($(uname_arch),aarch64)
                ARCH_FLAGS=$(SSE2NEON_FLAGS)
                INCLUDES+= $(SSE2NEON_INCLUDES)
endif
endif

override CXXFLAGS+=	-fpermissive $(ARCH_FLAGS) -DSORT_PAIRS -DENABLE_PREFETCH -DBWA_OTHER_ELE=0 -std=c++11 -fopenmp 
#VTUNE_HOME= /opt/intel/oneapi/vtune/2021.1.1
LIBS=		-fopenmp -lz -ldl

ifneq ($(VTUNE_HOME),)
CXXFLAGS+= -DVTUNE_ANALYSIS=1
INCLUDES+=	-I${VTUNE_HOME}/include
LIBS+=-L${VTUNE_HOME}/lib64 -littnotify
endif

.PHONY:all clean depend
.SUFFIXES:.cpp .o

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $(INCLUDES) $(ARCH_FLAGS) $< -o $@

all:$(EXE)

bsw:main_banded.o bandedSWA.o
	$(CXX) -o $@ $^ $(LIBS)

clean:
	rm -fr *.o $(EXE)


# DO NOT DELETE
main_banded.o: bandedSWA.h macro.h utils.h
bandedSWA.o: bandedSWA.h macro.h utils.h
