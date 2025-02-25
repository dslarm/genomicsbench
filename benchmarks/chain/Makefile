#CXX = icpc
CXX = g++

# path #
SRC_PATH = src
BUILD_PATH = build
BIN_PATH = $(BUILD_PATH)/bin

# executable #
BIN_NAME = chain

# extensions #
SRC_EXT = cpp

# code lists #
# Find all source files in the source directory, sorted by
# most recently modified
SOURCES = $(shell find $(SRC_PATH) -name '*.$(SRC_EXT)' | sort -k 1nr | cut -f2-)
# Set the object file names, with the source directory stripped
# from the path, and the build path prepended in its place
OBJECTS = $(SOURCES:$(SRC_PATH)/%.$(SRC_EXT)=$(BUILD_PATH)/%.o)
# Set the dependency files that will be used to add header dependencies
DEPS = $(OBJECTS:.o=.d)

uname_arch := $(shell uname -m)


ARCH_FLAGS=	-msse4.1
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


# flags #
#COMPILE_FLAGS = -std=c++11 -Wall -Wextra -g -O3 -fopenmp -xAVX2 -axAVX2
#VTUNE_HOME= /opt/intel/vtune_profiler
COMPILE_FLAGS = -std=c++11 -Wall -Wextra -g -O3 -fopenmp $(ARCH_FLAGS)
INCLUDES = -I../../tools/minimap2
# Space-separated pkg-config libraries used by this project
LIBS = -L../../tools/minimap2 -lminimap2 -ldl


ifneq ($(VTUNE_HOME),)
COMPILE_FLAGS += -DVTUNE_ANALYSIS=1
INCLUDES += -I${VTUNE_HOME}/include
LIBS +=  -L${VTUNE_HOME}/lib64 -littnotify
endif


.PHONY: default_target
default_target: release

.PHONY: release
release: export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS)
release: dirs
	@$(MAKE) all

.PHONY: dirs
dirs:
	@echo "Creating directories"
	@mkdir -p $(dir $(OBJECTS))
	@mkdir -p $(BIN_PATH)

.PHONY: clean
clean:
	@echo "Deleting $(BIN_NAME) symlink"
	@$(RM) $(BIN_NAME)
	@echo "Deleting directories"
	@$(RM) -r $(BUILD_PATH)
	@$(RM) -r $(BIN_PATH)

# checks the executable and symlinks to the output
.PHONY: all
all: $(BIN_PATH)/$(BIN_NAME)
	@echo "Making symlink: $(BIN_NAME) -> $<"
	@$(RM) $(BIN_NAME)
	@ln -s $(BIN_PATH)/$(BIN_NAME) $(BIN_NAME)

# Creation of the executable
$(BIN_PATH)/$(BIN_NAME): $(OBJECTS)
	@echo "Linking: $@"
	#$(CXX) -O3 -fopenmp -xAVX2 -axAVX2 $(OBJECTS) -o $@
	$(CXX) -O3 -fopenmp $(ARCH_FLAGS) $(OBJECTS) $(INCLUDES) $(LIBS) -o $@

# Add dependency files, if they exist
-include $(DEPS)

# Source file rules
# After the first compilation they will be joined with the rules from the
# dependency files to provide header dependencies
$(BUILD_PATH)/%.o: $(SRC_PATH)/%.$(SRC_EXT)
	@echo "Compiling: $< -> $@"
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(LIBS) -MP -MMD -c $< -o $@
