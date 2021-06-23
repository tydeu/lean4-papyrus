import Papyrus.Types.TypeRef

namespace Papyrus

/-- A fumction type. -/
structure FunctionType (α) (β) (varArgs : Bool) where
  resultType : α
  parameterTypes : β

/-- A function type with the given parameters and result. -/
def functionType (resultType : α) (parameterTypes : β) (varArgs := false) :=
  (FunctionType.mk resultType parameterTypes : FunctionType α β varArgs)

@[extern "papyrus_get_function_type"]
private constant getFunctionTypeRef
  (result : @& TypeRef)
  (params : @& Array TypeRef)
  (isVarArgs : Bool)
  : IO TypeRef

namespace FunctionType
variable {varArgs : Bool}

/-- Does this type have variable arguments? -/
def isVarArgs (self : FunctionType α β varArgs) := varArgs

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the result, parameters,
  and variable argument combination is valid.
-/
def getRef [ToTypeRef α] [ToTypeRefArray β] (self : FunctionType α β varArgs) : LLVM TypeRef := do
  getFunctionTypeRef (← toTypeRef self.resultType) (← toTypeRefArray self.parameterTypes) varArgs

end FunctionType

instance [ToTypeRef α] [ToTypeRefArray β]  {varArgs} : ToTypeRef (FunctionType α β varArgs) :=
  ⟨FunctionType.getRef⟩
