ifndef LEAN_HOME
LEAN ?= lean
LEAN_HOME := $(shell $(LEAN) --print-prefix)
endif

RMPATH := rm -rf
LEANMAKEFILE := ${LEAN_HOME}/share/lean/lean.mk
LEANMAKE := $(MAKE) -f $(LEANMAKEFILE)

all: plugin

clean: clean-c clean-lib clean-plugin clean-test

.PHONY: c lib plugin test clean

c:
	$(MAKE) -C c

clean-c:
	$(MAKE) -C c clean

lib:
	+$(LEANMAKE) PKG=Papyrus lib

clean-lib:
	$(RMPATH) build

plugin: lib c
	$(MAKE) -C plugin

clean-plugin:
	$(MAKE) -C plugin clean

test: plugin
	$(MAKE) -C test

clean-test:
	$(MAKE) -C test clean
