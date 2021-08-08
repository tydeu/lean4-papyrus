import Papyrus.Context
import Papyrus.IR.ModuleRef
import Papyrus.IR.FunctionRef
import Papyrus.IR.GlobalVariableRef
import Papyrus.IR.InstructionRefs

namespace Papyrus

-- # Module Builder

abbrev ModuleM := ReaderT ModuleRef LlvmM

protected def ModuleM.runIn (mod : ModuleRef) (self : ModuleM α) : LlvmM α :=
  self mod

-- # Basic Block Builder

structure BasicBlockContext where
  modRef : ModuleRef
  funRef : FunctionRef
  bbRef : BasicBlockRef

abbrev BasicBlockM := ReaderT BasicBlockContext LlvmM

instance : MonadLift ModuleM BasicBlockM where
  monadLift m := fun ctx => m ctx.modRef

protected def BasicBlockM.runIn (ctx : BasicBlockContext) (self : BasicBlockM α) : LlvmM α :=
  self ctx

namespace Actions

def module (name : String) (builder : ModuleM PUnit) : LlvmM ModuleRef := do
  let modRef ← ModuleRef.new name
  builder.runIn modRef
  return modRef

-- ## Module Actions

/-- Add a global variable to the module. -/
def globalVar (type : TypeRef)
(isConstant := false) (linkage := Linkage.external) (name : @& String := "")
(tlm := ThreadLocalMode.notLocal) (addrSpace := AddressSpace.default) (isExternallyInitialized := false)
: ModuleM GlobalVariableRef := do
  let gblRef ← GlobalVariableRef.new type isConstant linkage name tlm addrSpace isExternallyInitialized
  (← read).appendGlobalVariable gblRef
  return gblRef

/-- Add a global variable with an initializer to the module. -/
def globalVarInit (type : TypeRef)
(isConstant := false) (linkage := Linkage.external) (name : @& String := "")
(tlm := ThreadLocalMode.notLocal) (addrSpace := AddressSpace.default)
: ModuleM GlobalVariableRef := do
  let gblRef ← GlobalVariableRef.new type isConstant linkage name tlm addrSpace false
  (← read).appendGlobalVariable gblRef
  return gblRef

/-- Add a string constant to the module. -/
def string (str : String)
(name := "") (addrSpace := AddressSpace.default) (withNull := true) : ModuleM GlobalVariableRef := do
  let gblRef ← GlobalVariableRef.ofString str name addrSpace withNull
  (← read).appendGlobalVariable gblRef
  return gblRef

/-- Add a string constant to the module and return a constant pointer to its head. -/
def stringPtr (str : String)
(name := "") (addrSpace := AddressSpace.default) (withNull := true) : ModuleM ConstantRef := do
  let gblRef ← string str name addrSpace withNull
  let zeroRef ← ConstantWordRef.ofUInt32 0
  let ptrRef ← ConstantExprRef.getGetElementPtr gblRef #[zeroRef, zeroRef] true
  return ptrRef

/-- Add a arbitrary constant to the module. -/
def globalConst (init : ConstantRef)
(linkage := Linkage.linkOnceODR) (name := "")
(tlm := ThreadLocalMode.notLocal) (addrSpace := AddressSpace.default) : ModuleM GlobalVariableRef := do
  let gblRef ← GlobalVariableRef.ofConstant init true linkage name tlm addrSpace
  (← read).appendGlobalVariable gblRef
  return gblRef

/-- Add a function declaration to the module. -/
def declare (type : FunctionTypeRef) (name : String)
(linkage := Linkage.external) (addrSpace := AddressSpace.default) : ModuleM FunctionRef := do
  let funRef ← FunctionRef.create type name linkage addrSpace
  (← read).appendFunction funRef
  return funRef

/-- Define a new a function in the module. -/
def define (type : FunctionTypeRef) (builder : BasicBlockM PUnit) (name : String :=  "")
(linkage := Linkage.external) (addrSpace := AddressSpace.default) (entry : String := "") : ModuleM FunctionRef := do
  let funRef ← FunctionRef.create type name linkage addrSpace
  let bbRef ← BasicBlockRef.create entry
  funRef.appendBasicBlock bbRef
  let modRef ← read
  modRef.appendFunction funRef
  builder.runIn {modRef, funRef, bbRef}
  return funRef

-- ## Basic Block Actions

def call (fn : FunctionRef) (args : Array ValueRef := #[]) (name : String := "") : BasicBlockM InstructionRef := do
  let inst ← fn.createCall args name
  (← read).bbRef.appendInstruction inst
  return inst

def callAs (type : FunctionTypeRef) (fn : ValueRef) (args : Array ValueRef := #[]) (name : String := "") : BasicBlockM InstructionRef := do
  let inst ← CallInstRef.create type fn args name
  (← read).bbRef.appendInstruction inst
  return inst

def retVoid : BasicBlockM PUnit := do
  (← read).bbRef.appendInstruction <| ← ReturnInstRef.createVoid

def ret (val : ValueRef)  : BasicBlockM PUnit := do
  (← read).bbRef.appendInstruction <| ← ReturnInstRef.create val
