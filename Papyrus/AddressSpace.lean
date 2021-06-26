namespace Papyrus

/-- A numerically indexed address space. -/
structure AddressSpace where
  index : Nat

namespace AddressSpace

/-- The default address space (i.e., 0). -/
def default := mk 0

/-- Make an address space from a `Nat`. -/
def ofNat (n : Nat) := mk n

end AddressSpace

instance : Inhabited AddressSpace := ⟨AddressSpace.default⟩
instance {n} : OfNat AddressSpace n := ⟨AddressSpace.ofNat n⟩
