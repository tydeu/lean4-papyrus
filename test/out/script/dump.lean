import Papyrus

open Papyrus Script

-- # Module

llvm module hello do
  declare i8 @printf(i8*, ...)
  define i32 @main() do
    call @printf("Hello World"*)
    ret i32 0

#dump hello

-- # Types

#dump llvm type void
#dump llvm type i32
#dump llvm type i8 (i8*, ...)
#dump llvm type i8 addrspace(5)*
#dump llvm type {i32, float}
#dump llvm type [2 x i8]
#dump llvm type <4 x i64>
#dump llvm type <vscale x 4 x double>

-- # Constants

#dump llvm true
#dump llvm false
#dump llvm i8 255
#dump llvm i32 1
#dump llvm i64 -1
#dump llvm i128 1208925819614629174706188 -- 2^80 + 12
#dump llvm i128 -1208925819614629174706188
