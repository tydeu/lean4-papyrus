# Detect Lean

ifndef LEAN_HOME
LEAN ?= lean
LEAN_HOME := $(shell $(LEAN) --print-prefix)
endif

LEAN_INCLUDE := $(LEAN_HOME)/include

# Detect LLVM

LLVM_CONFIG	?= llvm-config
LLVM_CXX_FLAGS := $(shell $(LLVM_CONFIG) --cxxflags)

# Config

MKPATH := mkdir -p
RMPATH := rm -rf

CXX	:= c++
EXTRA_CXX_FLAGS := -O1

SRC_DIR := src
HDR_DIR := include
OUT_DIR := build

HDRS := \
	papyrus.h

SRCS := \
	common.cpp\
  context.cpp\
  module.cpp\

LIB_OBJ := papyrus.o

OBJ_FILES := $(addprefix $(OUT_DIR)/,$(SRCS:.cpp=.o))
HDR_FILES := $(addprefix $(HDR_DIR)/,$(HDRS))

# Build Rules

all: lib

lib: $(OUT_DIR)/$(LIB_OBJ)

$(OUT_DIR):
	$(MKPATH) $@

$(OUT_DIR)/$(LIB_OBJ) : $(OBJ_FILES) | $(OUT_DIR)
	$(CXX) -r -o $@ $^

$(OUT_DIR)/%.o : $(SRC_DIR)/%.cpp $(HDR_FILES) | $(OUT_DIR)
	$(CXX) -o $@ -c $< -I$(HDR_DIR) -I$(LEAN_INCLUDE) $(LLVM_CXX_FLAGS) $(EXTRA_CXX_FLAGS)

clean:
	$(RMPATH) $(OUT_DIR)
