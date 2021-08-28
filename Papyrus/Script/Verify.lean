import Papyrus.Script.SyntaxUtil
import Papyrus.IR.FunctionRef
import Papyrus.IR.ModuleRef

namespace Papyrus.Script

-- # Verify Class

class VerifyRef (α : Type u) where
  verifyRef : α → IO PUnit

export VerifyRef (verifyRef)

class Verify (α : Type u) where
  verify : α → LlvmM PUnit

export Verify (verify)

instance [VerifyRef α] : Verify α := ⟨liftM ∘ verifyRef⟩

instance : VerifyRef FunctionRef := ⟨FunctionRef.verify⟩
instance : VerifyRef ModuleRef := ⟨fun m => discard <| ModuleRef.verify m⟩

-- # Verify Command

macro kw:"#verify " x:term : command => do
  mkEvalAt kw <| ← ``(LlvmM.run ($x >>= verify))
