open Lean Syntax
namespace Papyrus.Script

def mkEvalAt (tk : Syntax) (stx : Syntax) : Syntax :=
  mkNode `Lean.Parser.Command.eval #[mkAtomFrom tk "#eval ", stx]

def identAsStrLit (id : Syntax) : Syntax :=
  mkStrLit (info := SourceInfo.fromRef id) <| id.getId.toString (escape := false)

def mkCAppFrom (src : Syntax) (fn : Name) (args : Array Syntax) : Syntax :=
  mkApp (mkCIdentFrom src fn) args

def mkNumLitFrom (src : Syntax) (val : String) :=
  mkNumLit val (SourceInfo.fromRef src)
