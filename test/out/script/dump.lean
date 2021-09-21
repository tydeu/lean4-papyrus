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


-- # Ops

llvm module ops do
  define i32 @opsEx(i32 %a, i32 %b) do
    %c = add i32 %a, %b
    %d = mul i32 %a, %b
    %e = sub i32 %a, %b
    %f = udiv i32 %a, %b 
    %g = sdiv i32 %a, %b 
    %h = urem i32 %a, %b
    %i = srem i32 %a, %b
    %j = shl i32 %a, %b
    %k = lshr i32 %a, %b
    %l = ashr i32 %a, %b
    %m = and i32 %a, %b
    %n = or i32 %a, %b
    %o = xor i32 %a, %b
    ret i32 0

  define i32 @mulEx(i32 %a, i32 %b) do
    %d = mul i32 %a, %b
    ret i32 0

  define float @fopsEx(float %a, float %b) do
    %c = fadd float %a, %b
    %d = fsub float %a, %b
    %e = fmul float %a, %b
    %f = fdiv float %a, %b
    %g = frem float %a, %b
    ret i32 0


#dump ops