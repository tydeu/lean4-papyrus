import Papyrus

open Papyrus Script

llvm module lean_hello do
  declare %lean_object* @lean_mk_string(i8*)
  declare %lean_object* @l_IO_println___at_Lean_instEval___spec__1(%lean_object*, %lean_object*)
  define i32 @main() do
   %hello = call @lean_mk_string("Hello World!"*)
   call @l_IO_println___at_Lean_instEval___spec__1(%hello, %hello)
   ret i32 0

#dump lean_hello
#verify lean_hello
#jit lean_hello

llvm module lean_echo do
  declare %lean_object* @lean_mk_string(i8*)
  declare %lean_object* @l_IO_println___at_Lean_instEval___spec__1(%lean_object*, %lean_object*)
  define i32 @main(i32 %argc, i8** %argv) do
    %arg1p = getelementptr i8*, %argv, i32 1
    %arg1 = load i8*, %arg1p
    %arg1s = call @lean_mk_string(%arg1)
    call @l_IO_println___at_Lean_instEval___spec__1(%arg1s, %arg1s)
    ret i32 0

#dump lean_echo
#verify lean_echo
#jit lean_echo #["a", "b", "c"]

llvm module lean_select do
  declare %lean_object* @lean_mk_string(i8*)
  declare %lean_object* @l_IO_println___at_Lean_instEval___spec__1(%lean_object*, %lean_object*)
  define i32 @main(i32 %argc, i8** %argv) do
    br1:
      %arg1p = getelementptr i8*, %argv, i32 1
      %arg1 = load i8*, %arg1p
      %arg1s = call @lean_mk_string(%arg1)
      call @l_IO_println___at_Lean_instEval___spec__1(%arg1s, %arg1s)
      ret i32 0
    br2:
      %arg2p = getelementptr i8*, %argv, i32 2
      %arg2 = load i8*, %arg2p
      %arg2s = call @lean_mk_string(%arg2)
      call @l_IO_println___at_Lean_instEval___spec__1(%arg2s, %arg2s)
      ret i32 0;
    %arg0 = load i8*, %argv
    %arg0c = load i1, %arg0
    br %arg0c, %br1, %br2

#dump lean_select
#verify lean_select
#jit lean_select #["some", "b", "c"]
#jit lean_select #["\x00", "b", "c"]
