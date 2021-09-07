import Lean.Parser.Command

open Lean Parser Command

namespace Papyrus.Internal

def mkSealedEnumReprInst (ty : Syntax) (ctors : Array Syntax) : MacroM Syntax := do
  let currNamespace ← Macro.getCurrNamespace
  let ctorFmts ← ctors.mapM fun ctor =>
    `(Std.format $(quote <| toString (currNamespace ++ ctor[2].getId)))
  `(def reprFormats : Array Std.Format := #[$[$ctorFmts],*]
    instance : Repr $ty := ⟨fun e _ => reprFormats[e.val.val]⟩)

def unpackOptDeriving : (stx : Syntax) → (Array Syntax × Array (Option Syntax))
| `(optDeriving| deriving $[$clss $[with $argss?]?],*) => (clss, argss?)
| _ => (#[], #[])


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
  -- structure
  defs := defs.push <| ←
    `($mods:declModifiers
      structure $id where
        val : $type
        $deriv?:optDeriving)
  -- constructors
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
  let mut innerDefs := #[]
  let numCtors := ctors.size
  let maxValLit := quote (numCtors - 1)
  -- filter out special deriving instances
  let mut derivBEq := false
  let mut derivDecEq := false
  let mut derivInhabited := false
  let mut derivRepr := false
  let mut remClasses := #[]
  let mut remArgss? := #[]
  let (classes, argss?) := unpackOptDeriving deriv?
  for cls in classes, args? in argss? do
    if cls.matchesIdent ``BEq then
      derivBEq := true
    else if cls.matchesIdent ``DecidableEq then
      derivDecEq := true
    else if cls.matchesIdent ``Inhabited then
      derivInhabited := true
    else if cls.matchesIdent ``Repr then
      derivRepr := true
    else
      remClasses := remClasses.push cls
      remArgss? := remArgss?.push args?
  -- structure
  let structDecl ←
    `($mods:declModifiers
      structure $id where
        val : $type
        h : val ≤ $maxValLit
        deriving $[$remClasses $[with $remArgss?]?],*)
  -- maximum
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
  -- derive special instance
  if derivBEq then
    innerDefs := innerDefs.push <| ←
      `(instance : BEq $id := ⟨fun a b => a.val == b.val⟩)
  if derivDecEq then
    innerDefs := innerDefs.push <| ←
      `(instance : DecidableEq $id := fun a b =>
          if h : a.val = b.val
            then isTrue (eq_of_val_eq h)
            else isFalse (ne_of_val_ne h))
  if derivInhabited then
    innerDefs := innerDefs.push <| ←
      `(instance : Inhabited $id := ⟨mk maxVal (Nat.le_refl _)⟩)
  if derivRepr then
    innerDefs := innerDefs.push <| ← mkSealedEnumReprInst id ctors
  -- syntax
  `($structDecl:command
    namespace $id:ident
    $(mkNullNode innerDefs)
    end $id:ident)
