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

# Configure Test Lib

TESTLIB_HOME			:= ./lib
TESTLIB_BUILD_DIR	:= $(TESTLIB_HOME)/build
TESTLIB_OLEAN_DIR	:= $(TESTLIB_BUILD_DIR)
TESTLIB_OLEAN    	:= $(TESTLIB_OLEAN_DIR)/TestLib.olean
TESTLIB_LIB    		:= $(TESTLIB_BUILD_DIR)/lib/libTestLib.a

# Other Config

CXX			:= c++
LEAN		:= lean
LEANC 	:= leanc

MKPATH 	:= mkdir -p
RMPATH 	:= rm -rf

COMP_DIR := comp
EVAL_DIR := eval
BUILD_DIR := build
TEST_OUT_DIR := out
LEANC_FLAGS	:=

SRCS :=\
	unit.lean\

EVALS :=\
	script/type.lean\
	script/value.lean

BINS := $(addprefix $(BUILD_DIR)/,$(SRCS:.lean=))

# Rules

all: bin test

clean: clean-bin clean-test

# Test Suite Build Rules

bin: $(BINS)

$(BUILD_DIR):
	$(MKPATH) $@

$(BUILD_DIR)/%.c : $(COMP_DIR)/%.lean $(PAPYRUS_LIB) $(TESTLIB_OLEAN) | $(BUILD_DIR)
	LEAN_PATH="$(PAPYRUS_OLEAN_DIR);$(TESTLIB_OLEAN_DIR)" $(LEAN) -c $@ $<

$(BUILD_DIR)/%.o : $(BUILD_DIR)/%.c | $(BUILD_DIR)
	$(LEANC) -c -o $@ $< $(LEANC_FLAGS)

$(BUILD_DIR)/% : $(BUILD_DIR)/%.o $(PAPYRUS_C_LIB) $(TESTLIB_LIB) | $(BUILD_DIR)
	$(LEANC) -o $@ $< $(PAPYRUS_LD_FLAGS) $(PAPYRUS_LIBS) $(TESTLIB_LIB)

.PRECIOUS: $(BUILD_DIR)/%.c

clean-bin:
	$(RMPATH) $(BUILD_DIR)

# Testing Rules

test: test-eval test-comp

test-comp: bin
	@echo "Compiled tests:"
	$(BUILD_DIR)/unit

test-eval: pre-test-eval $(EVALS)

pre-test-eval:
	@echo "Interpreted tests:"

$(EVALS):
	@echo "Testing $@ ... "
	@cd ${EVAL_DIR}; ./test_single.sh $@

clean-test-eval:
	$(RMPATH) ${EVAL_DIR}/**/*.lean.produced.out

clean-test-out:
	$(RMPATH) $(TEST_OUT_DIR)

clean-test: clean-test-out clean-test-eval
