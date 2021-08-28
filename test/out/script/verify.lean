import Papyrus
open Papyrus Script

llvm module foo do
  define i32 @main() do
    ret i32 0

#verify foo
#verify foo >>= (·.getFunction "main")

llvm module bug do
  define i32 @main() do
    ret i8 0

#verify bug -- Error: Function return type does not match operand
#verify bug >>= (·.getFunction "main") -- Same Error
