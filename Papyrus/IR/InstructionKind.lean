import Papyrus.Internal.Enum

namespace Papyrus

open Internal

/-- Tags for all of the instruction types of LLVM (v12) IR.  -/
sealed-enum InstructionKind : UInt8
-- terminator
| ret
| branch
| switch
| indirectBr
| invoke
| resume
| unreachable
| cleanupRet
| catchRet
| catchSwitch
| callBr
-- unary
| fneg
-- binary
| add
| fadd
| sub
| fsub
| mul
| fmul
| udiv
| sdiv
| fdiv
| urem
| srem
| frem
-- bitwise
| shl
| lshr
| ashr
| and
| or
| xor
-- memory
| alloca
| load
| store
| getElementPtr
| fence
| atomicCmpXchg
| atomicRMW
-- casts
| trunc
| zext
| sext
| fpToUI
| fpToSI
| uiToFP
| siToFP
| fpTrunc
| fpExt
| ptrToInt
| intToPtr
| bitcast
| addrSpaceCast
-- pad
| cleanupPad
| catchPad
-- other
| icmp
| fcmp
| phi
| call
| select
| userOp1
| userOp2
| vaarg
| extractElement
| insertElement
| shuffleVector
| extractValue
| insertValue
| landingPad
| freeze
deriving Inhabited, BEq, DecidableEq, Repr

namespace InstructionKind

def ofOpcode! (opcode : UInt32) : InstructionKind :=
  let id := opcode - 1 |>.toUInt8
  if h : id ≤ maxVal then
    mk id h
  else
    panic! s!"unknown LLVM opcode {opcode}"

def toOpcode (self : InstructionKind) : UInt32 :=
  self.val.toUInt32 + 1
