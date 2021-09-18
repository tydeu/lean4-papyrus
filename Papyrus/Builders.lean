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

namespace Builder

def module (name : String) (builder : ModuleM PUnit) : LlvmM ModuleRef := do
  let modRef ← ModuleRef.new name
  builder.runIn modRef
  return modRef

-- ## Module Builder Actions

/-- Add a global variable to the module. -/
def globalVar (type : TypeRef)
(isConstant := false) (linkage := Linkage.external) (name : @& String := "")
(tlm := ThreadLocalMode.notLocal) (addrSpace := AddressSpace.default) (isExternallyInitialized := false)
: ModuleM GlobalVariableRef := do
  let gblRef ← GlobalVariableRef.new type isConstant linkage name tlm addrSpace isExternallyInitialized
  (← read).appendGlobalVariable gblRef
  return gblRef

/-- Add a global variable with an initializer to the module. -/
def globalVarInit (init : ConstantRef)
(isConstant := false) (linkage := Linkage.external) (name : @& String := "")
(tlm := ThreadLocalMode.notLocal) (addrSpace := AddressSpace.default)
: ModuleM GlobalVariableRef := do
  let gblRef ← GlobalVariableRef.ofConstant init isConstant linkage name tlm addrSpace
  (← read).appendGlobalVariable gblRef
  return gblRef

/-- Add a string constant to the module. -/
def string (str : String)
(addrSpace := AddressSpace.default) (withNull := true) (name := "")
: ModuleM GlobalVariableRef := do
  let gblRef ← GlobalVariableRef.ofString str addrSpace withNull name
  (← read).appendGlobalVariable gblRef
  return gblRef

/-- Add a string constant to the module and return a constant pointer to its head. -/
def stringPtr (str : String)
(addrSpace := AddressSpace.default) (withNull := true) (name := "")
: ModuleM ConstantRef := do
  let gblRef ← string str addrSpace withNull name
  let zeroRef ← ConstantIntRef.ofUInt32 0
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

-- ## Basic Block Builder Actions

def getArg (argNo : UInt32) : BasicBlockM ArgumentRef := do
  (← read).funRef.getArg argNo

def label (name : String) (builder : BasicBlockM PUnit) : BasicBlockM BasicBlockRef := do
  let ctx ← read
  let bb ← BasicBlockRef.create name
  ctx.funRef.appendBasicBlock bb
  builder.runIn {ctx with bbRef := bb}
  return bb

-- ### `ret`

def retVoid : BasicBlockM PUnit := do
  (← read).bbRef.appendInstruction <| ← ReturnInstRef.createVoid

def ret (val : ValueRef)  : BasicBlockM PUnit := do
  (← read).bbRef.appendInstruction <| ← ReturnInstRef.create val

-- ### `br`

def condBr (cond : ValueRef) (ifTrue ifFalse : BasicBlockRef)  : BasicBlockM PUnit := do
  (← read).bbRef.appendInstruction <| ← CondBrInstRef.create ifTrue ifFalse cond

def br (bb : BasicBlockRef)  : BasicBlockM PUnit := do
  (← read).bbRef.appendInstruction <| ← BrInstRef.create bb

-- ### `load`

def load (type : TypeRef) (ptr : ValueRef) (name := "") (isVolatile := false)
  (align : Align := 1) (order := AtomicOrdering.notAtomic) (ssid := SyncScopeID.system)
  : BasicBlockM InstructionRef := do
  let inst ← LoadInstRef.create type ptr name isVolatile align order ssid
  (← read).bbRef.appendInstruction inst
  return inst

-- ### `store`

def store (val : ValueRef) (ptr : ValueRef) (isVolatile := false)
  (align : Align := 1) (order := AtomicOrdering.notAtomic) (ssid := SyncScopeID.system)
  : BasicBlockM InstructionRef := do
  let inst ← StoreInstRef.create val ptr isVolatile align order ssid
  (← read).bbRef.appendInstruction inst
  return inst

-- ### `getelementptr`

def getElementPtr
(pointeeType : TypeRef) (ptr : ValueRef) (indices : Array ValueRef := #[])
(name : String := "") : BasicBlockM InstructionRef := do
  let inst ← GetElementPtrInstRef.create pointeeType ptr indices name
  (← read).bbRef.appendInstruction inst
  return inst

def getElementPtrInbounds
(pointeeType : TypeRef) (ptr : ValueRef) (indices : Array ValueRef := #[])
(name : String := "") : BasicBlockM InstructionRef := do
  let inst ← GetElementPtrInstRef.createInbounds pointeeType ptr indices name
  (← read).bbRef.appendInstruction inst
  return inst

-- ### `call`

def call (fn : FunctionRef) (args : Array ValueRef := #[]) (name : String := "") : BasicBlockM InstructionRef := do
  let inst ← fn.createCall args name
  (← read).bbRef.appendInstruction inst
  return inst

def callAs (type : FunctionTypeRef) (fn : ValueRef) (args : Array ValueRef := #[]) (name : String := "") : BasicBlockM InstructionRef := do
  let inst ← CallInstRef.create type fn args name
  (← read).bbRef.appendInstruction inst
  return inst

-- ### `phi`
def phi (ty : TypeRef) (args : Array (ValueRef × BasicBlockRef) := #[]) (name : String := "") : BasicBlockM InstructionRef := do
  let inst ← PHINodeRef.create ty
  for (value, block) in args do
    inst.addIncoming value block
  (← read).bbRef.appendInstruction inst
  return inst