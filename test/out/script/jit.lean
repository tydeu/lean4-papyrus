import Papyrus

open Papyrus Script

llvm module exit do
  define i32 @main() do
   ret i32 101

#jit exit

llvm module echo do
  define i32 @main(i32 %argc) do
   ret %argc

#jit echo #["a", "b", "c"]

llvm module empty do
  pure ()

#jit empty -- Error: Module has no main function
