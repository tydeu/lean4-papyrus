# Detect Lean

ifndef LEAN_HOME
LEAN ?= lean
LEAN_HOME := $(shell $(LEAN) --print-prefix)
endif

LEAN_INCLUDE := $(LEAN_HOME)/include

# Detect LLVM

LLVM_CONFIG	?= llvm-config
LLVM_CXX_FLAGS := $(shell $(LLVM_CONFIG) --cxxflags)

# Detect OS

OS_NAME := ${OS}
ifneq ($(OS_NAME),Windows_NT)
OS_NAME := $(shell uname -s)
endif

# Config

MKPATH := mkdir -p
RMPATH := rm -rf

AR := ar
CXX	:= c++

EXTRA_CXX_FLAGS := -O3 -DNDEBUG
ifneq ($(OS_NAME),Windows_NT)
EXTRA_CXX_FLAGS += -fPIC
endif

SRC_DIR := src
HDR_DIR := include
OUT_DIR := build/$(OS_NAME)

HDRS := \
	papyrus.h\
	papyrus_ffi.h

SRCS := \
	adt.cpp\
	init.cpp\
	memory_buffer.cpp\
  context.cpp\
  module.cpp\
	bitcode.cpp\
	type.cpp\
	value.cpp\
	constant.cpp\
	instruction.cpp\
	basic_block.cpp\
	global.cpp\
	global_variable.cpp\
	function.cpp\
	generic_value.cpp\
	execution_engine.cpp\

LIB_NAME := PapyrusC
LIB := lib${LIB_NAME}.a

OBJ_FILES := $(addprefix $(OUT_DIR)/,$(SRCS:.cpp=.o))
HDR_FILES := $(addprefix $(HDR_DIR)/,$(HDRS))

# Build Rules

all: lib

lib: $(OUT_DIR)/$(LIB)

$(OUT_DIR):
	$(MKPATH) $@

$(OUT_DIR)/$(LIB) : $(OBJ_FILES) | $(OUT_DIR)
	${AR} rcs $@ $^

$(OUT_DIR)/%.o : $(SRC_DIR)/%.cpp $(HDR_FILES) | $(OUT_DIR)
	$(CXX) -o $@ -c $< -I$(HDR_DIR) -I$(LEAN_INCLUDE) $(LLVM_CXX_FLAGS) $(EXTRA_CXX_FLAGS)

clean:
	$(RMPATH) $(OUT_DIR)
