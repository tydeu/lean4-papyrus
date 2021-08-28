import Papyrus

open Papyrus Script

llvm module exit do
  define i32 @main() do
   ret i32 101

#jit exit

llvm module echo do
  define i32 @main(argc : i32) do
   ret %argc

#jit echo #["a", "b", "c"]

llvm module empty do
  pure ()

#jit empty -- Error: Module has no main function

llvm module lean_hello do
  declare %lean_object* @lean_mk_string(i8*)
  declare %lean_object* @l_IO_println___at_Lean_instEval___spec__1(%lean_object*, %lean_object*);
  define i32 @main() do
   %hello = call @lean_mk_string("Hello World!"*)
   call @l_IO_println___at_Lean_instEval___spec__1(%hello, %hello)
   ret i32 0

#jit lean_hello
