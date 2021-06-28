import Papyrus.IR.TypeRefs

namespace Papyrus

/-- A function type. -/
structure FunctionType (α) (β) (varArgs : Bool) where
  resultType : α
  parameterTypes : β

/-- A function type with the given parameters and result. -/
def functionType (resultType : α) (parameterTypes : β) (varArgs := false) :=
  (FunctionType.mk resultType parameterTypes : FunctionType α β varArgs)

namespace FunctionType
variable {varArg : Bool}

/-- Does this function type have variable arguments? -/
def isVarArg (self : FunctionType α β varArg) := varArg

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the result, parameters,
  and variable argument combination is valid.
-/
def getRef [ToTypeRef α] [ToTypeRefArray β] (self : FunctionType α β varArg) : LLVM FunctionTypeRef := do
  FunctionTypeRef.get (← toTypeRef self.resultType) (← toTypeRefArray self.parameterTypes) varArg

end FunctionType

instance [ToTypeRef α] [ToTypeRefArray β]  {varArg} : ToTypeRef (FunctionType α β varArg) :=
  ⟨FunctionType.getRef⟩
