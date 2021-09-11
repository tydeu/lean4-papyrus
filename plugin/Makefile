# Detect Lean

LEAN  ?= lean
LEANC ?= leanc

# Detect LLVM

LLVM_CONFIG	?= llvm-config

LLVM_COMPONENTS :=\
	core bitreader bitwriter executionengine mcjit interpreter all-targets

LLVM_LD_FLAGS   := $(shell $(LLVM_CONFIG) --link-static --ldflags)
LLVM_LIBS       := $(shell $(LLVM_CONFIG) --link-static --libs $(LLVM_COMPONENTS))
LLVM_SYS_LIBS   := $(shell $(LLVM_CONFIG) --link-static --system-libs) -lffi
LLVM_LIB_FLAGS	:= $(LLVM_LD_FLAGS) $(LLVM_LIBS) $(LLVM_SYS_LIBS)

# Detect OS

OS_NAME := ${OS}
ifneq ($(OS_NAME),Windows_NT)
OS_NAME := $(shell uname -s)
endif

# Config

MV := mv
RM := rm

MKPATH := mkdir -p
RMPATH := ${RM} -rf

OUT_DIR := build

LEAN_OUT := ../build/$(OS_NAME)
LEAN_PATH := $(LEAN_OUT)

LIB_NAME := Papyrus
LIB_DIR := $(LEAN_OUT)/lib
LIB := lib${LIB_NAME}.a

ifeq ($(OS_NAME),Darwin)
LIB_FLAGS = -Wl,-all_load -l$(LIB_NAME) -Wl,-noall_load
else
LIB_FLAGS = -Wl,--whole-archive -l$(LIB_NAME) -Wl,--no-whole-archive
endif

C_LIB_NAME := PapyrusC
C_LIB_DIR := ../c/build/$(OS_NAME)
C_LIB := lib${C_LIB_NAME}.a

PLUGIN := PapyrusPlugin

ifeq ($(OS_NAME),Windows_NT)
SHARED_LIB_EXT := dll
else
SHARED_LIB_EXT := so
endif

PLUGIN_LIB := ${PLUGIN}.$(SHARED_LIB_EXT)

# Build Rules

all: plugin

$(OUT_DIR):
	$(MKPATH) $@

clean:
	$(RMPATH) $(OUT_DIR)

# Plugin Build

plugin: $(OUT_DIR)/${PLUGIN_LIB}

$(OUT_DIR)/${PLUGIN_LIB}: $(OUT_DIR)/${PLUGIN}.c $(C_LIB_DIR)/$(C_LIB) $(LIB_DIR)/$(LIB) | $(OUT_DIR)
# rename old lib in case it can't be replaced (e.g., because it is in use)
	-${MV} $@ $@.tmp
	${LEANC} -shared -o $@ $< -L${LIB_DIR} ${LIB_FLAGS} -L${C_LIB_DIR} -l${C_LIB_NAME} ${LLVM_LIB_FLAGS}
# try to delete old lib
	${RM} -f $@.tmp


$(OUT_DIR)/${PLUGIN}.c: ${PLUGIN}.lean | $(OUT_DIR)
	LEAN_PATH=${LEAN_PATH} $(LEAN) -c $@ $<
