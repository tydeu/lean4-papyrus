import Papyrus

open Papyrus Script

llvm module lean_hello do
  declare %lean_object* @lean_mk_string(i8*)
  declare %lean_object* @l_IO_println___at_Lean_instEval___spec__1(%lean_object*, %lean_object*);
  define i32 @main() do
   %hello = call @lean_mk_string("Hello World!"*)
   call @l_IO_println___at_Lean_instEval___spec__1(%hello, %hello)
   ret i32 0

#dump lean_hello
#verify lean_hello
#jit lean_hello
