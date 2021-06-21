# Detect Lean

ifndef LEAN_HOME
LEAN ?= lean
LEAN_HOME := $(shell $(LEAN) --print-prefix)
endif

LEAN_INCLUDE := $(LEAN_HOME)/include

# Detect LLVM

ifndef LLVM_HOME
LLVM_CONFIG	?= llvm-config
LLVM_HOME := $(shell $(LLVM_CONFIG) --prefix)
else
LLVM_CONFIG	:= $(LLVM_HOME)/bin/llvm-config
endif

LLVM_CXX_FLAGS := $(shell $(LLVM_CONFIG) --cxxflags)

# Config

CXX	:= c++
EXTRA_CXX_FLAGS := -O1
INCLUDE_DIR := include

OUT := build
LIB_OBJ := lean_llvm.o

SRCS := \
	common.cpp\
  context.cpp\
  module.cpp\

OBJS=$(addprefix $(OUT)/,$(SRCS:.cpp=.o))

# Build Rules

all: lib

lib: $(OUT)/$(LIB_OBJ)

$(OUT):
	mkdir -p $@

$(OUT)/$(LIB_OBJ) : $(OBJS) | $(OUT)
	$(CXX) -r -o $@ $^

$(OUT)/%.o : src/%.cpp | $(OUT)
	$(CXX) -o $@ -c $< -I$(INCLUDE_DIR) -I$(LEAN_INCLUDE) $(LLVM_CXX_FLAGS) $(EXTRA_CXX_FLAGS)

clean:
	rm -rf $(OUT)
