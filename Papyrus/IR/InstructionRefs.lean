import Papyrus.Context
import Papyrus.IR.ValueRef
import Papyrus.IR.InstructionRef
import Papyrus.IR.TypeRefs
import Papyrus.IR.ConstantRefs
import Papyrus.IR.FunctionRef

namespace Papyrus

--------------------------------------------------------------------------------
-- Call Instructions
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [CallBase](https://llvm.org/doxygen/classllvm_1_1CallBase.html).
-/
def CallBaseRef := InstructionRef

/--
  A reference to an external LLVM
  [CallInst](https://llvm.org/doxygen/classllvm_1_1CallInst.html).
-/
def CallInstRef := InstructionRef

namespace CallInstRef

/-- Create a new unlinked call instruction. -/
@[extern "papyrus_call_inst_create"]
constant create (type : @& FunctionTypeRef) (fn : @& ValueRef) (args : @& Array ValueRef)
  (name : @& String := "") : IO CallInstRef

end CallInstRef

namespace FunctionRef

/-- Create an unlinked call instruction that invokes this function. -/
def createCall
(args : @& Array ValueRef) (self : @& FunctionRef) (name : @& String := "")
: IO CallInstRef := do
  CallInstRef.create (← self.getType) self args name

end FunctionRef

--------------------------------------------------------------------------------
-- Return Instructions
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [ReturnInst](https://llvm.org/doxygen/classllvm_1_1ReturnInst.html).
-/
def ReturnInstRef := InstructionRef

namespace ReturnInstRef

/-- Create a new unlinked void return instruction. -/
@[extern "papyrus_return_inst_create_void"]
constant createVoid : LlvmM ReturnInstRef

/-- Create a new unlinked return instruction. -/
@[extern "papyrus_return_inst_create"]
constant create (retVal : @& ValueRef) : LlvmM ReturnInstRef

/-- Create a new unlinked i1 return instruction. -/
def createBool (retVal : Bool) : LlvmM ReturnInstRef := do
  create (← ConstantIntRef.ofBool retVal)

/-- Create a new unlinked i8 return instruction. -/
def createUInt8 (retVal : UInt8) : LlvmM ReturnInstRef := do
  create (← ConstantIntRef.ofUInt8 retVal)

/-- Create a new unlinked i16 return instruction. -/
def createUInt16 (retVal : UInt16) : LlvmM ReturnInstRef := do
  create (← ConstantIntRef.ofUInt16 retVal)

/-- Create a new unlinked i32 return instruction. -/
def createUInt32 (retVal : UInt32) : LlvmM ReturnInstRef := do
  create (← ConstantIntRef.ofUInt32 retVal)

/-- Create a new unlinked i64 return instruction. -/
def createUInt64 (retVal : UInt64) : LlvmM ReturnInstRef := do
  create (← ConstantIntRef.ofUInt64 retVal)

/-- Get a reference to the returned value. -/
@[extern "papyrus_return_inst_get_value"]
constant getReturnValue (self : @& ReturnInstRef) : IO (Option ValueRef)

end ReturnInstRef
