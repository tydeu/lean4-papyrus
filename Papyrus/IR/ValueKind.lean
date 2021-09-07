import Papyrus.Internal.Enum

namespace Papyrus

open Internal

/-- Tags for all of LLVM (v12) IR value types. -/
sealed-enum ValueKind : UInt8
| function
| globalAlias
| globalIFunc
| globalVariable
| blockAddress
| constantExpr
| dsoLocalEquivalent
| constantArray
| constantStruct
| constantVector
| undef
| poison
| constantAggregateZero
| constantDataArray
| constantDataVector
| constantInt
| constantFP
| constantPointerNull
| constantTokenNone
| argument
| basicBlock
| metadataAsValue
| inlineAsm
| memoryUse
| memoryDef
| memoryPhi
| instruction
deriving Inhabited, BEq, DecidableEq, Repr

namespace ValueKind

def ofValueID! (id : UInt32) : ValueKind :=
  let id := id.toUInt8
  if h : id ≤ maxVal then
    mk id h
  else
    instruction

def toValueID (self : ValueKind) : UInt32 :=
  self.val.toUInt32
