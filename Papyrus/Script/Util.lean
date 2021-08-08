open Lean

namespace Papyrus.Script

def identAsStrLit (id : Syntax) : Syntax :=
  Syntax.mkStrLit <| id.getId.toString (escape := false)
