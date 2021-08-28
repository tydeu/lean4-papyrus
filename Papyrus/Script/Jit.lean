import Papyrus.Script.SyntaxUtil
import Papyrus.ExecutionEngineRef

namespace Papyrus.Script

/-- Verifies a module and runs its `main` function with the given arguments and environment. -/
def jitMain (mod : ModuleRef) (args : Array String := #[]) (env : Array String := #[])
: IO UInt32 := do
  discard <| mod.verify
  match (← mod.getFunction? "main") with
  | some fn => do
    let ee ← ExecutionEngineRef.createForModule mod
    ee.runFunctionAsMain fn args env
  | none => throw <| IO.userError "Module has no main function"

macro kw:"#jit " mod:term:arg args?:optional(term:arg) env?:optional(term:arg) : command => do
  let args := args?.getD (← `(#[])); let env := env?.getD (← `(#[]))
  mkEvalAt kw <| ← `(LlvmM.run do jitMain (← $mod) $args $env)
