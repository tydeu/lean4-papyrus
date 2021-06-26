import Papyrus.Types.TypeRef

namespace Papyrus

-- # Function Type Reference

/--
  A reference to the LLVM representation of a
  [FunctionType](https://llvm.org/doxygen/classllvm_1_1FunctionType.html).
-/
def FunctionTypeRef := TypeRef

namespace FunctionTypeRef

/--
  Get a reference to the LLVM function type with
    the given result and parameter types.
  It is the user's responsibility to ensure that they are valid.
-/
@[extern "papyrus_get_function_type"]
constant get (result : @& TypeRef) (params : @& Array TypeRef)
  (isVarArg := false) : IO FunctionTypeRef

/-- Get a reference to the return type of this function type. -/
@[extern "papyrus_function_type_get_return_type"]
constant getReturnType (self : @& FunctionTypeRef) : IO TypeRef

/-- Get an array of references to the parameter types of this function type. -/
@[extern "papyrus_function_type_get_parameter_types"]
constant getParameterTypes (self : @& FunctionTypeRef) : IO (Array TypeRef)

/-- Get whether this function type accepts variable arguments. -/
@[extern "papyrus_function_type_is_var_arg"]
constant isVarArg (self : @& FunctionTypeRef) : IO Bool

end FunctionTypeRef

-- # Pure Function Type

/-- A fumction type. -/
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
