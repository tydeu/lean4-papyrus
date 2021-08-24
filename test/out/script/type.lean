import Papyrus.Script.Type

open Papyrus Script

-- # Floating Point Types

#check llvm type half
#check llvm type bfloat
#check llvm type float
#check llvm type double
#check llvm type x86_fp80
#check llvm type fp128
#check llvm type ppc_fp128

-- # Special Types

#check llvm type void
#check llvm type label
#check llvm type metadata
#check llvm type x86_mmx
#check llvm type x86_amx
#check llvm type token

-- # Integer Types

#check i1
#check i32
#check i1942652

#check llvm type i1
#check llvm type i32
#check llvm type i1942652

-- # Function Types

#check llvm type i32 (i32)
#check llvm type float (i16, i32 *) *
#check llvm type i32 (i8*, ...)
#check llvm type {i32, i32} (i32)

-- # Pointer Types

#check i8*

#check llvm type i8*
#check llvm type [4 x i32]*
#check llvm type i32 (i32*) *
#check llvm type i32 addrspace(5) *

-- # (Literal) Struct Types

#check llvm type { i32, i32, i32 }
#check llvm type { float, i32 (i32) * }
#check llvm type <{ i8, i32 }>

-- # Array Types

#check llvm type [40 x i32]
#check llvm type [41 x i32]
#check llvm type [4 x i8]

#check llvm type [3 x [4 x i32]]
#check llvm type [12 x [10 x float]]
#check llvm type [2 x [3 x [4 x i16]]]

-- # Vector Types

#check llvm type <4 x i32>
#check llvm type <8 x float>
#check llvm type <2 x i64>
#check llvm type < 4 x i64* >
#check llvm type <vscale x 4 x i32>

-- # Nested Terms

#check llvm type [4 × type(int8Type)]
#check llvm type { type(int8Type), type(floatType) }

-- #check llvm type <4 x i64*> -- fails: `*>` is a separate token

-- #check llvm type %X
-- #check llvm type %T1 { i32, i32, i32 }
-- #check llvm type %T2 <{ i8, i32 }>
