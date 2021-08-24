# Config

MKPATH 	:= mkdir -p
RMPATH 	:= rm -rf

TEST_RUN := ./test_run.sh
TEST_OUT := ./test_out.sh
TEST_MAIN := ./test_main.sh

RUN_TEST_DIR := run
OUT_TEST_DIR := out
MAIN_TEST_DIR := main

RUN_TESTS := $(wildcard $(RUN_TEST_DIR)/**/*.lean)
OUT_TESTS := $(wildcard $(OUT_TEST_DIR)/**/*.lean)
MAIN_TESTS := $(wildcard $(MAIN_TEST_DIR)/*.lean)

TESTS := $(MAIN_TESTS) $(RUN_TESTS) $(OUT_TESTS)

TEST_TMP_DIR := tmp

# Rules

all: test

test: $(TESTS)

clean: clean-out clean-tmp-dir

$(MAIN_TESTS):
	@echo "Testing $@ ... "
	@$(TEST_MAIN) $@

$(RUN_TESTS):
	@echo "Testing $@ ... "
	@$(TEST_RUN) $@

$(OUT_TESTS):
	@echo "Testing $@ ... "
	@$(TEST_OUT) $@

clean-out:
	$(RMPATH) ${SRC_DIR}/**/*.lean.produced.out

clean-tmp-dir:
	$(RMPATH) $(TEST_OUT_DIR)

.PHONY: all test clean clean-out clean-tmp-dir $(TESTS)
