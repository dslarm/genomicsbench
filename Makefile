CXX=g++
CC=gcc
ARCH=avx2
#VTUNE_HOME=/opt/intel/oneapi/vtune/2021.1.1
MKLROOT=/opt/intel/oneapi/mkl/2021.1.1
MKL_IOMP5_DIR=/opt/intel/oneapi/compiler/2021.1.2/linux/compiler/lib/intel64_lin
CUDA_LIB=/usr/local/cuda


uname_arch := $(shell uname -m)



ifeq ($(uname_arch),aarch64)
MINIMAP_FLAGS=arm_neon=1 aarch64=1 -f Makefile.simde CFLAGS='-O3 -mcpu=native -g'
endif


.PHONY: clean

TARGETS=fmi bsw dbg phmm chain poa pileup kmer-cnt
all: $(TARGETS)

htslib:
	cd tools/htslib && autoreconf -i && ./configure && $(MAKE) LDFLAGS="-fopenmp"

bwa-mem2:
	cd tools/bwa-mem2 ; $(MAKE) CC=$(CC) CXX=$(CXX) VTUNE_HOME=$(VTUNE_HOME)

fmi:	bwa-mem2
	cd benchmarks/fmi; $(MAKE) CXX=$(CXX) VTUNE_HOME=$(VTUNE_HOME)

bsw:
	cd benchmarks/bsw; $(MAKE) CXX=$(CXX) VTUNE_HOME=$(VTUNE_HOME)


dbg:	htslib
	cd benchmarks/dbg; $(MAKE) CXX=$(CXX)  VTUNE_HOME=$(VTUNE_HOME)

gkl_phmm:
	cd tools/GKL;  ./gradlew cmakeConfig -Pcxx=$(CXX) -Pcc=$(CC) -Pcflags="$(CFLAGS)" && make -C build/native/src/main/native/pairhmm  && make -C build/native/src/main/native/pairhmm  install

phmm:	gkl_phmm
	cd benchmarks/phmm; $(MAKE) CC=$(CC)  VTUNE_HOME=$(VTUNE_HOME)

minimap2:
	cd tools/minimap2; $(MAKE) $(MINIMAP_FLAGS)

chain:	minimap2
	cd benchmarks/chain; $(MAKE)  CXX=$(CXX)  VTUNE_HOME=$(VTUNE_HOME)

spoa:
	cd tools/spoa; mkdir build; cd build; cmake -DCMAKE_BUILD_TYPE=Release -Dspoa_optimize_for_native=OFF ..; $(MAKE)

poa:	spoa
	cd benchmarks/poa; $(MAKE) CXX=$(CXX)  VTUNE_HOME=$(VTUNE_HOME)


pileup: htslib
	cd benchmarks/pileup; CC=$(CC) $(MAKE)  VTUNE_HOME=$(VTUNE_HOME)

kmer-cnt:
	cd benchmarks/kmer-cnt; $(MAKE) CXX=$(CXX) VTUNE_HOME=$(VTUNE_HOME)

#grm:	htslib
#	cd benchmarks/grm/2.0/build_dynamic; $(MAKE) CC=$(CC) CXX=$(CXX) arch=$(ARCH) VTUNE_HOME=$(VTUNE_HOME) MKLROOT=$(MKLROOT) MKL_IOMP5_DIR=$(MKL_IOMP5_DIR) #needs MKL




gpu:
	cd benchmarks/abea; $(MAKE) CUDA_LIB=$(CUDA_LIB)

clean:
	cd tools/bwa-mem2; $(MAKE) clean
	cd benchmarks/fmi; $(MAKE) clean
	cd benchmarks/bsw; $(MAKE) clean
	cd benchmarks/dbg; $(MAKE) clean
	cd tools/htslib; $(MAKE) clean
	cd tools/GKL; ./gradlew clean
	cd benchmarks/phmm; $(MAKE) clean
	cd tools/minimap2; $(MAKE)
	cd benchmarks/chain; $(MAKE) clean
	cd benchmarks/poa; $(MAKE) clean
	cd benchmarks/pileup; $(MAKE) clean
	cd benchmarks/kmer-cnt; $(MAKE) clean
	cd benchmarks/grm/2.0/build_dynamic; $(MAKE) clean


