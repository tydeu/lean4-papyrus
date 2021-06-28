namespace Papyrus

/-- A numerically indexed address space. -/
structure AddressSpace where
  index : Nat
  deriving BEq, Repr

namespace AddressSpace

/-- The default address space (i.e., 0). -/
def default := mk 0

/-- Make an address space from a `Nat`. -/
def ofNat (n : Nat) := mk n

/-- Make an address space from a `UInt32`. -/
def ofUInt32 (n : UInt32) := mk n.toNat

/-- Convert an address space tp a `Nat`. -/
def toNat (self : AddressSpace) := self.index

/-- Convert an address space to a `UInt32`. -/
def toUInt32 (self : AddressSpace) := self.index.toUInt32

end AddressSpace

instance : Inhabited AddressSpace := ⟨AddressSpace.default⟩
instance {n} : OfNat AddressSpace n := ⟨AddressSpace.ofNat n⟩
