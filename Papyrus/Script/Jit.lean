import Papyrus.Script.SyntaxUtil
import Papyrus.ExecutionEngineRef

namespace Papyrus.Script

/-- Run the  `main` function of a module with the given arguments and environment. -/
def jitMain (mod : ModuleRef) (args : Array String := #[]) (env : Array String := #[])
: IO PUnit := do
  match (← mod.getFunction? "main") with
  | some fn => do
    let ee ← ExecutionEngineRef.createForModule mod
    let rc ← ee.runFunctionAsMain fn args env
    IO.println s!"Exited with code {rc}"
  | none => throw <| IO.userError "Module has no main function"

macro kw:"#jit " mod:term:arg args?:optional(term:arg) env?:optional(term:arg) : command => do
  let args := args?.getD (← `(#[])); let env := env?.getD (← `(#[]))
  mkEvalAt kw <| ← `(LlvmM.run do jitMain (← $mod) $args $env)
