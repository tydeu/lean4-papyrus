import Lean.Parser.Command

open Lean Parser Command

namespace Papyrus.Internal

set_option hygiene false

--------------------------------------------------------------------------------
-- # Open Enums
--------------------------------------------------------------------------------

syntax enumCtor := "\n| " declModifiers ident " := " term

scoped macro (name := enumDecl)
  mods:declModifiers
  "enum " id:ident " : " type:term optional(" := " <|> " where ")
  ctors:many(enumCtor)
  deriv?:optDeriving
: command => do
  let mut defs : Array Syntax := #[]
  defs := defs.push <| ←
    `($mods:declModifiers
      structure $id where
        val : $type
        $deriv?:optDeriving)
  for ctor in ctors do
    let ctorId := ctor[2]
    let ctorQualId := mkIdentFrom ctorId <|
      id.getId.modifyBase (· ++ ctorId.getId)
    let ctorVal := ctor[4]
    let ctorMods := ctor[1]
    defs := defs.push <| ←
      `($ctorMods:declModifiers def $ctorQualId:ident : $id := mk $ctorVal)
  mkNullNode defs

--------------------------------------------------------------------------------
-- # Sealed Enums
--------------------------------------------------------------------------------

syntax identCtor := "\n| " declModifiers ident

scoped macro (name := sealedEnumDecl)
  mods:declModifiers
  "sealed-enum " id:ident " : " type:term optional(" := " <|> " where ")
  ctors:many(identCtor)
  deriv?:optDeriving
: command => do
  let numCtors := ctors.size
  let maxValLit := quote (numCtors - 1)
  -- structure
  let structDecl ←
    `($mods:declModifiers
      structure $id where
        val : $type
        h : val ≤ $maxValLit
        $deriv?:optDeriving)
  -- maximum
  let mut innerDefs := #[]
  innerDefs := innerDefs.push <| ←
    `(def maxVal : $type := $maxValLit)
  -- theorems
  innerDefs := innerDefs.push <| ←
    `(theorem eq_of_val_eq : {a b : $id} → a.val = b.val → a = b
        | ⟨v, h⟩, ⟨_, _⟩, rfl => rfl
      theorem val_eq_of_eq {a b : $id} (h : a = b) : a.val = b.val :=
        h ▸ rfl
      theorem ne_of_val_ne {a b : $id} (h : a.val ≠ b.val) : a ≠ b :=
        fun h' => absurd (val_eq_of_eq h') h)
  -- constructors
  for ctor in ctors, i in [:numCtors] do
    let ctorVal := quote i
    let ctorMods := ctor[1]
    let ctorId := ctor[2]
    innerDefs := innerDefs.push <| ←
      `($ctorMods:declModifiers def $ctorId:ident : $id := mk $ctorVal (by decide))
  -- syntax
  `($structDecl:command
    namespace $id:ident
    $(mkNullNode innerDefs)
    end $id:ident)
