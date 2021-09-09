namespace Papyrus

/--
  A valid (non-zero power of two) alignment.

  LLVM alignments are in terms of bytes (i.e. an alignment of 1 is byte-aligned).
-/
structure Align where
  shiftVal : UInt8
  h : shiftVal < 64
  deriving Repr

-- TODO: Add way to compute `Align` from a raw alignment.
namespace Align

def val (self : Align) : UInt64 :=
  (1 : UInt64) <<< self.shiftVal.toUInt64

partial def ofValAux (i : UInt8) (n : UInt64) : UInt8 :=
  if n < 2 then i else ofValAux (i + 1) (n / 2)

def ofVal (n : UInt64) : Align :=
  mk (ofValAux 0 n % (64 : Nat)) <| Fin.modn_lt _ (Nat.zero_lt_succ _)

-- ## OfNat Instances

section
open Lean

local macro "gen_ofNat_instances" : command => do
  let mut instances := Array.mkEmpty 64
  for i in [0:64] do
    let shiftVal := quote i
    let val := quote <| 1 <<< i
    instances := instances.push <| ←
      `(instance : OfNat Align (nat_lit $val) := ⟨⟨$shiftVal, by decide⟩⟩)
  mkNullNode instances

gen_ofNat_instances
end

/-- The default is byte-aligned. -/
def default : Align := 1

instance : Inhabited Align := ⟨Align.default⟩

-- ## Propositional Relations

theorem eq_of_shiftVal_eq : {a b : Align} → a.shiftVal = b.shiftVal → a = b
  | ⟨v, h⟩, ⟨_, _⟩, rfl => rfl

theorem shiftVal_eq_of_eq {a b : Align} (h : a = b) : a.shiftVal = b.shiftVal :=
  h ▸ rfl

theorem ne_of_shiftVal_ne {a b : Align} (h : a.shiftVal ≠ b.shiftVal) : a ≠ b :=
  fun h' => absurd (shiftVal_eq_of_eq h') h

instance decEq : DecidableEq Align :=
  fun a b =>
    if h : a.shiftVal = b.shiftVal
    then isTrue (eq_of_shiftVal_eq h)
    else isFalse (ne_of_shiftVal_ne h)

instance : LT Align := ⟨fun a b => a.shiftVal < b.shiftVal⟩
instance : LE Align := ⟨fun a b => a.shiftVal <= b.shiftVal⟩

instance decLt (a b : Align) : Decidable (a < b)  := UInt8.decLt ..
instance decLe (a b : Align) : Decidable (a <= b) := UInt8.decLe ..
