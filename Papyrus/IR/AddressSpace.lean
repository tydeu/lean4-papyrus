namespace Papyrus

/--
  A numerically indexed address space.
  Implemented as a `def` rather than a `structure` so the
  it will be passed unboxed (as a `uint32`) to external functions.
-/
def AddressSpace := UInt32

instance : BEq AddressSpace := inferInstanceAs (BEq UInt32)
instance : DecidableEq AddressSpace := inferInstanceAs (DecidableEq UInt32)
instance : Repr AddressSpace := inferInstanceAs (Repr UInt32)

namespace AddressSpace

/-- The default address space (i.e., 0). -/
def default : AddressSpace := (0 : UInt32)

/-- Make an address space from a `Nat`. -/
def ofNat (n : Nat) : AddressSpace  := n.toUInt32

/-- Make an address space from a `UInt32`. -/
def ofUInt32 (n : UInt32) : AddressSpace := n

/-- Convert an address space tp a `Nat`. -/
def toNat (self : AddressSpace) : Nat := UInt32.toNat self

/-- Convert an address space to a `UInt32`. -/
def toUInt32 (self : AddressSpace) : UInt32 := self

end AddressSpace

instance : Inhabited AddressSpace := ⟨AddressSpace.default⟩
instance {n} : OfNat AddressSpace n := ⟨AddressSpace.ofNat n⟩
