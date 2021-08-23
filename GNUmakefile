ifndef LEAN_HOME
LEAN ?= lean
LEAN_HOME := $(shell $(LEAN) --print-prefix)
endif

RMPATH := rm -rf
LEANMAKEFILE := ${LEAN_HOME}/share/lean/lean.mk
LEANMAKE := $(MAKE) -f $(LEANMAKEFILE)

all: plugin

clean: clean-c clean-lib clean-plugin clean-testlib clean-test

.PHONY: c lib plugin testlib test clean

c:
	$(MAKE) -C c

clean-c:
	$(MAKE) -C c clean

lib:
	+$(LEANMAKE) PKG=Papyrus lib

build/%.lean:
	+$(LEANMAKE) PKG=Papyrus $@

clean-lib:
	$(RMPATH) build

plugin: lib c
	$(MAKE) -C plugin

clean-plugin:
	$(MAKE) -C plugin clean

testlib:
	+$(LEANMAKE) -C test/lib lib

clean-testlib:
	$(RMPATH) test/lib/build

test: testlib plugin
	$(MAKE) -C test

clean-test:
	$(MAKE) -C test clean
