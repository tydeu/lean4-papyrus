namespace Papyrus

/-- An object which defines the kind of an external pointer. -/
constant ExternalPtrClass : Type := Unit

/-- A Lean object which contains an external pointer. -/
constant ExternalPtr : ExternalPtrClass → Type → Type := fun _ _ => Unit

/- The external class of LoosePtr. -/
axiom LoosePtr.class : ExternalPtrClass

/-- An external pointer with no memory management. -/
abbrev LoosePtr (α) := ExternalPtr Papyrus.LoosePtr.class α

/- The external class of LoosePtr. -/
axiom OwnedPtr.class : ExternalPtrClass

/--
  A external pointer that is deleted upon being garbage collected
  (i.e., it is owned by Lean).
-/
abbrev OwnedPtr (α) := ExternalPtr Papyrus.OwnedPtr.class α

/-- The actual implementation of `LinkedPtr`. -/
structure LinkedPtrImpl (k : ExternalPtrClass) (σ) (α) where
  link : σ
  this : ExternalPtr k α

/--
  A external pointer whose lifetime is linked to some other external object
  that should not be deleted until this one is garbage collected by Lean.

  It as an opaque definition to prevent access to the internal `ExternalPtr`,
  which could create memory mismanagement (e.g., if a reference to it is kept
  without keeping a reference to the `LinkedPtr`).
-/
constant LinkedPtr (k : ExternalPtrClass) (σ : Type) (α : Type) : Type :=
  LinkedPtrImpl k σ α

/--  A linked external pointer that should not be managed by Lean. -/
abbrev LinkedLoosePtr := LinkedPtr LoosePtr.class

/--  A linked external pointer that can be deleted independently by Lean. -/
abbrev LinkedOwnedPtr := LinkedPtr OwnedPtr.class
