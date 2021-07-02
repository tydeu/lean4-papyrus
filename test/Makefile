# Configure Papyrus

PAPYRUS_HOME 			:= ..
PAPYRUS_LIBDIR	 	:= $(PAPYRUS_HOME)/build/lib
PAPYRUS_C_LIBDIR	:= $(PAPYRUS_HOME)/c/build
PAPYRUS_OLEAN_DIR := $(PAPYRUS_HOME)/build

LLVM_COMPONENTS :=\
	core bitreader bitwriter executionengine mcjit interpreter all-targets

LLVM_CONFIG 			?= llvm-config
LLVM_LD_FLAGS   	:= $(shell $(LLVM_CONFIG) --ldflags)
LLVM_LIBS       	:= $(shell $(LLVM_CONFIG) --libs $(LLVM_COMPONENTS))
LLVM_SYS_LIBS   	:= $(shell $(LLVM_CONFIG) --system-libs)
LLVM_LIB_FLAGS		:= $(LLVM_LD_FLAGS) $(LLVM_LIBS) $(LLVM_SYS_LIBS)

PAPYRUS_LIB 			:= $(PAPYRUS_LIBDIR)/libPapyrus.a
PAPYRUS_C_LIB			:= ${PAPYRUS_C_LIBDIR}/libPapyrusC.a
PAPYRUS_LIBS			:= -lPapyrus -lPapyrusC $(LLVM_LIBS) $(LLVM_SYS_LIBS)
PAPYRUS_LD_FLAGS	:= -L$(PAPYRUS_LIBDIR) -L$(PAPYRUS_C_LIBDIR) $(LLVM_LD_FLAGS)

# Configure test library

TESTLIB_HOME			:= ./lib
TESTLIB_BUILD_DIR	:= $(TESTLIB_HOME)/build
TESTLIB_OLEAN_DIR	:= $(TESTLIB_BUILD_DIR)
TESTLIB_OLEAN    	:= $(TESTLIB_OLEAN_DIR)/TestLib.olean
TESTLIB_LIB    		:= $(TESTLIB_BUILD_DIR)/lib/libTestLib.a
TESTLIB_OPTS			:=

# Other Config

CXX			:= c++
LEAN		:= lean
LEANC 	:= leanc

MKPATH 	:= mkdir -p
RMPATH 	:= rm -rf

LLVM_BINDIR := $(shell $(LLVM_CONFIG) --bindir)
LLC	:= $(LLVM_BINDIR)/llc

SRC_DIR := src
OUT_DIR := build
TEST_OUT_DIR := out
LEANC_FLAGS	:= -O1

SRCS :=\
	unit.lean\

BINS := $(addprefix $(OUT_DIR)/,$(SRCS:.lean=))

# Rules

all: bin test

# Build Rules

bin: $(BINS)

$(OUT_DIR):
	$(MKPATH) $@

$(TESTLIB_OLEAN):
	cd $(TESTLIB_HOME) && leanpkg build

$(TESTLIB_LIB): $(TESTLIB_OLEAN)
	cd $(TESTLIB_HOME) && leanpkg build lib

$(OUT_DIR)/%.c : $(SRC_DIR)/%.lean $(PAPYRUS_LIB) $(TESTLIB_OLEAN) | $(OUT_DIR)
	LEAN_PATH="$(PAPYRUS_OLEAN_DIR);$(TESTLIB_OLEAN_DIR)" $(LEAN) -c $@ $<

$(OUT_DIR)/%.o : $(OUT_DIR)/%.c | $(OUT_DIR)
	$(LEANC) -c -o $@ $< $(LEANC_FLAGS)

$(OUT_DIR)/% : $(OUT_DIR)/%.o $(PAPYRUS_C_LIB) $(TESTLIB_LIB) | $(OUT_DIR)
	$(LEANC) -o $@ $< $(PAPYRUS_LD_FLAGS) $(PAPYRUS_LIBS) $(TESTLIB_LIB)

.PRECIOUS: $(OUT_DIR)/%.c

clean-bin:
	$(RMPATH) $(OUT_DIR)

testlib: $(TESTLIB_OLEAN) $(TESTLIB_LIB)

clean-testlib:
	$(RMPATH) $(TESTLIB_BUILD_DIR)

clean-build: clean-bin clean-testlib

# Test Rules

test: bin
	$(OUT_DIR)/unit
	@echo "checking produced bitcode"
	$(LLC) -o $(TEST_OUT_DIR)/exit.s $(TEST_OUT_DIR)/exit.bc
	$(CXX) -o $(TEST_OUT_DIR)/exit $(TEST_OUT_DIR)/exit.s
	-$(TEST_OUT_DIR)/exit
	@echo "error 101 expected"

clean-test:
	$(RMPATH) $(TEST_OUT_DIR)

clean: clean-build clean-test
