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


EXE=		fmi
#CXX=		icpx
CXX=		g++
#VTUNE_HOME= /opt/intel/oneapi/vtune/2021.1.1
ARCH_FLAGS=	-msse4.1

uname_arch := $(shell uname -m)

SSE2NEON_FLAGS=-D__SSE2__=1 -D__AVX__=1 -D__SSE4_1__=1
SSE2NEON_INCLUDES=-I../../tools/bwa-mem2/ext/sse2neon
BWAMEM2_PATH=../../tools/bwa-mem2
INCLUDES=	-I$(BWAMEM2_PATH)/src -I$(BWAMEM2_PATH)/ext/safestringlib/include 
LIBS=		-L$(BWAMEM2_PATH) -L$(BWAMEM2_PATH)/ext/safestringlib -lsafestring -fopenmp -lz -lbwa -ldl


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

CXXFLAGS=	-std=c++11 -fopenmp $(ARCH_FLAGS) #-mtune=native -march=native
#CPPFLAGS=	-DPRINT_OUTPUT -DENABLE_PREFETCH -DBWA_OTHER_ELE=0
CPPFLAGS=	-DENABLE_PREFETCH -DBWA_OTHER_ELE=0

ifneq ($(VTUNE_HOME),)
CPPFLAGS+=	-DVTUNE_ANALYSIS=1
INCLUDES+=	-I${VTUNE_HOME}/include
LIBS+=-L${VTUNE_HOME}/lib64 -littnotify
endif

.PHONY:all clean depend
.SUFFIXES:.cpp .o

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $(INCLUDES) $(ARCH_FLAGS) $< -o $@

all:$(EXE)

fmi:fmi.o $(BWAMEM2_PATH)/libbwa.a
	$(CXX) -o $@ $^ $(LIBS)

clean:
	rm -fr *.o $(EXE)


# DO NOT DELETE

fmi.o: $(BWAMEM2_PATH)/src/FMI_search.h $(BWAMEM2_PATH)/src/bntseq.h $(BWAMEM2_PATH)/src/read_index_ele.h
fmi.o: $(BWAMEM2_PATH)/src/bwa.h $(BWAMEM2_PATH)/src/bwt.h $(BWAMEM2_PATH)/src/utils.h $(BWAMEM2_PATH)/src/macro.h
