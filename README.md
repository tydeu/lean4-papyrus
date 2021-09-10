# Papyrus

A **work-in-progress** LLVM interface for Lean 4.

Inspired by [`lean-llvm`](https://github.com/GaloisInc/lean-llvm), which is Copyright (c) 2019 Galois, Inc. and released under the Apache 2.0 license, which can be found here: http://www.apache.org/licenses/LICENSE-2.0.

More documentation will come as development progresses. In fact, the source files are pretty well documented already (if I do say so myself), so feel free to take a look at them.

## Demo

In addition to Lean/C bindings to LLVM, Papyrus also provides a DSL for writing and interacting with LLVM IR. It is still very much a work-in-progress, but here is a little sample of what it can do at the moment:

```lean
import Papyrus

open Papyrus Script

llvm module lean_hello do
  declare %lean_object* @lean_mk_string(i8*)
  declare %lean_object* @l_IO_println___at_Lean_instEval___spec__1(%lean_object*, %lean_object*)
  define i32 @main() do
   %hello = call @lean_mk_string("Hello World!"*)
   call @l_IO_println___at_Lean_instEval___spec__1(%hello, inttoptr (i32 1 to %lean_object*))
   ret i32 0

#dump lean_hello -- Prints the module's IR
#verify lean_hello -- Checks that the IR is valid
#jit lean_hello -- JITs the `main` function

/- #jit:
Hello World
Exited with code 0
-/
```

**Note:** To run this code, you will need to provide the `PapyrusPlugin` shared library (located at `papyrus/plugin/build` after a build) to Lean as a plugin (e.g., by providing `--plugin papyrus/plugin/build/PapyrusPlugin` as an argument).
