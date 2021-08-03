import Papyrus.IR.Type
import Papyrus.IR.TypeBases
import Papyrus.IR.AddressSpace

namespace Papyrus

--------------------------------------------------------------------------------
-- # Special Types
--------------------------------------------------------------------------------

/-- An empty type. -/
abbrev voidType := Type.void

/-- A label type. -/
abbrev labelType := Type.label

/-- A metadata type. -/
abbrev metadataType := Type.metadata

/-- A token type. -/
abbrev tokenType := Type.token

/-- A 64-bit X86 MMX vector type. -/
abbrev x86MMXType := Type.x86MMX

/-- An 8192-bit X86 MMX vector type. -/
abbrev x86AMXType := Type.x86AMX

--------------------------------------------------------------------------------
-- # Floating Point Types
--------------------------------------------------------------------------------

/-- An IEEE half precision (16-bit) floating point type. -/
abbrev halfType := Type.half

/-- A brain floating point. A 16-bit (7-bit significand) floating point type. -/
abbrev bfloatType := Type.bfloat

/-- An IEEE single precision (32-bit) floating point type. -/
abbrev floatType := Type.float

/-- An IEEE double precision (64-bit) floating point type. -/
abbrev doubleType := Type.double

/-- An X86/X87 80-bit floating point type. -/
abbrev x86FP80Type := Type.x86FP80

/-- An IEEE quadruple precision (128-bit) floating point type. -/
abbrev fp128Type := Type.fp128

/-- A PowerPC double double. A 128-bit floating point type that sums two IEEE doubles. -/
abbrev ppcFP128Type := Type.ppcFP128

--------------------------------------------------------------------------------
-- # IntegerType
--------------------------------------------------------------------------------

instance : Coe IntegerType «Type» := ⟨Type.integer⟩

/--
  Get a reference to an external LLVM representation of this type.
  It is the user's responsible to ensure that the bit width of the type falls
  within the LLVM's requirements (i.e., that `isValidBitWidth numBits` holds).
-/
def IntegerType.getRef (self : IntegerType) : LlvmM IntegerTypeRef :=
  IntegerTypeRef.get self.bitWidth

/-- Lift this reference to a pure `IntegerType`. -/
def IntegerTypeRef.purify (self : IntegerTypeRef) : IO IntegerType := do
  IntegerType.mk (← self.getBitWidth)

--------------------------------------------------------------------------------
-- # FunctionType
--------------------------------------------------------------------------------

/--
  A pure representation of an LLVM
  [FunctionType](https://llvm.org/doxygen/classllvm_1_1FunctionType.html).
-/
abbrev FunctionType := BaseFunctionType «Type»
instance : Coe FunctionType «Type» := ⟨Type.function⟩

/-- A function type with the given parameters and return type. -/
def functionType (ret : «Type») (params : Array «Type») (isVarArg := false) : FunctionType :=
  BaseFunctionType.mk ret params isVarArg

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the configuration is valid.
-/
def FunctionType.getRef (self : FunctionType) : LlvmM FunctionTypeRef := do
  FunctionTypeRef.get (← self.returnType.getRef)
    (← self.parameterTypes.mapM (·.getRef)) self.isVarArg

/-- Lift this reference to a pure `FunctionType`. -/
def FunctionTypeRef.purify (self : FunctionTypeRef) : IO FunctionType := do
  let ret ← (← self.getReturnType).purify
  let params ← (← self.getParameterTypes).mapM (·.purify)
  functionType ret params (← self.isVarArg)

--------------------------------------------------------------------------------
-- # PointerType
--------------------------------------------------------------------------------

/--
  A pure representation of an LLVM
  [PointerType](https://llvm.org/doxygen/classllvm_1_1PointerType.html).
-/
abbrev PointerType := BasePointerType «Type»
instance : Coe PointerType «Type» := ⟨Type.pointer⟩

/-- A pointer type pointing to the given type in the given address space. -/
def pointerType (pointee : «Type») (addrSpace := AddressSpace.default) : PointerType :=
  BasePointerType.mk pointee addrSpace

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the configuration is valid.
-/
def PointerType.getRef (self : PointerType) : LlvmM PointerTypeRef := do
  PointerTypeRef.get (← self.pointeeType.getRef) self.addressSpace

/-- Lift this reference to a pure `PointerType`. -/
def PointerTypeRef.purify (self : PointerTypeRef) : IO PointerType := do
  pointerType (← (← self.getPointeeType).purify) (← self.getAddressSpace)

--------------------------------------------------------------------------------
-- # StructType
--------------------------------------------------------------------------------

/--
  The body of a `StructType`.
  An aggregate of zero or more element types laid out sequentially in memory.
  If `isPacked` is true, no padding will be added between elements.
-/
abbrev StructTypeBody := BaseStructTypeBody «Type»
abbrev StructTypeBody.mk (elems : Array «Type») (isPacked := false) : StructTypeBody :=
  BaseStructTypeBody.mk elems isPacked

/--
  A pure representation of an LLVM
  [StructType](https://llvm.org/doxygen/classllvm_1_1StructType.html).
-/
abbrev StructType := BaseStructType «Type»
instance : Coe StructType «Type» := ⟨Type.struct⟩

namespace StructType

/--
  A literal struct type.
  Literal struct types are unique by their body.
-/
@[matchPattern]
abbrev literal (body : StructTypeBody) : StructType :=
  BaseStructType.literal body

/--
  An identified struct type.
  Identified struct types are unique by their name if they have one
    (i.e., if their name is non-empty).
  They can also be opaque (have no body specified).
-/
@[matchPattern]
abbrev identified (name : String) (body? : Option StructTypeBody) : StructType :=
  BaseStructType.identified name body?

/-- An opaque (identified) struct type with given name. -/
@[matchPattern]
abbrev opaque (name : String) : StructType :=
  BaseStructType.opaque name

/-- A non-opaque identified struct type with given name and body. -/
@[matchPattern]
abbrev complete (name : String) (body : StructTypeBody) : StructType :=
  BaseStructType.complete name body

end StructType

/--
  A complete identified struct type with
  the given name, element types, and packing.
-/
def structType (name : String) (elementTypes : Array «Type») (isPacked := false) : StructType :=
  StructType.complete name ⟨elementTypes, isPacked⟩

/-- A literal struct type with the given element types and packing. -/
def literalStructType (elementTypes : Array «Type») (isPacked := false) : StructType :=
  StructType.literal ⟨elementTypes, isPacked⟩

/-- An opaque identified struct type with the given name. -/
def opaqueStructType (name : String) : StructType :=
  StructType.opaque name

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the configuration is valid.
-/
def StructType.getRef : (self : StructType) → LlvmM StructTypeRef
| literal ⟨elemTypes, isPacked⟩ => do
    LiteralStructTypeRef.get (← elemTypes.mapM (·.getRef)) isPacked
| complete name ⟨elemTypes, isPacked⟩ => do
  IdentifiedStructTypeRef.create name (← elemTypes.mapM (·.getRef)) isPacked
| opaque name =>
  IdentifiedStructTypeRef.createOpaque name

/-- Lift this reference to a pure literal `StructType`. -/
def LiteralStructTypeRef.purify (self : LiteralStructTypeRef) : IO StructType := do
  StructType.literal ⟨← (← self.getElementTypes).mapM (·.purify), ← self.isPacked⟩

/-- Lift this reference to a pure identified `StructType`. -/
def IdentifiedStructTypeRef.purify (self : IdentifiedStructTypeRef) : IO StructType := do
  if (← self.isOpaque) then
    StructType.opaque (← self.getName)
  else
    let params ← (← self.getElementTypes).mapM (·.purify)
    StructType.complete (← self.getName) ⟨params, ← self.isPacked⟩

/-- Lift this reference to a pure `StructType`. -/
def StructTypeRef.purify (self : StructTypeRef) : IO StructType := do
  if (← self.isLiteral) then
    LiteralStructTypeRef.purify self
  else
    IdentifiedStructTypeRef.purify self

--------------------------------------------------------------------------------
-- # ArrayType
--------------------------------------------------------------------------------

/--
  A pure representation of an LLVM
  [ArrayType](https://llvm.org/doxygen/classllvm_1_1ArrayType.html).
-/
abbrev ArrayType := BaseArrayType «Type»
instance : Coe ArrayType «Type» := ⟨Type.array⟩

/-- An array type of the given element type with the given size. -/
def arrayType (elemType : «Type») (size : UInt64) : ArrayType :=
  BaseArrayType.mk elemType size

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the configuration is valid.
-/
def ArrayType.getRef (self : ArrayType) : LlvmM ArrayTypeRef := do
  ArrayTypeRef.get (← self.elementType.getRef) self.size

/-- Lift this reference to a pure `ArrayType`. -/
def ArrayTypeRef.purify (self : ArrayTypeRef) : IO ArrayType := do
  arrayType (← (← self.getElementType).purify) (← self.getSize)

--------------------------------------------------------------------------------
-- # Vector Types
--------------------------------------------------------------------------------

-- ## VectorType

/--
  A pure representation of an LLVM
  [VectorType](https://llvm.org/doxygen/classllvm_1_1VectorType.html).
-/
abbrev VectorType := BaseVectorType «Type»

/-- A SIMD vector type of the given element type with the given size and the given scalability. -/
def vectorType (elemType : «Type») (size : UInt32) (isScalable := false) : VectorType :=
  BaseVectorType.mk ⟨elemType, size⟩ isScalable

/- Lift this to a generic `Type`. -/
def VectorType.toType (self : VectorType) : «Type» :=
  if self.isScalable then
    Type.scalableVector ⟨self.toBaseAbstractVectorType⟩
  else
    Type.fixedVector ⟨self.toBaseAbstractVectorType⟩

instance : Coe VectorType «Type» := ⟨VectorType.toType⟩

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the configuration is valid.
-/
def VectorType.getRef (self : VectorType) : LlvmM VectorTypeRef := do
  VectorTypeRef.get (← self.elementType.getRef) self.minSize self.isScalable

/-- Lift this reference to a pure `VectorType`. -/
def VectorTypeRef.purify (self : VectorTypeRef) : IO VectorType := do
  vectorType (← (← self.getElementType).purify) (← self.getMinSize) (← self.isScalable)

-- ## FixedVectorType

/--
  A pure representation of an LLVM
  [FixedVectorType](https://llvm.org/doxygen/classllvm_1_1FixedVectorType.html).
-/
abbrev FixedVectorType := BaseFixedVectorType «Type»
instance : Coe FixedVectorType «Type» := ⟨Type.fixedVector⟩

/-- A fixed-length SIMD vector type of the given element type with the given size. -/
def fixedVectorType (elemType : «Type») (size : UInt32) : FixedVectorType :=
  BaseFixedVectorType.mk ⟨elemType, size⟩

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the configuration is valid.
-/
def FixedVectorType.getRef (self : FixedVectorType) : LlvmM FixedVectorTypeRef := do
  FixedVectorTypeRef.get (← self.elementType.getRef) self.size

/-- Lift this reference to a pure `ArrayType`. -/
def FixedVectorTypeRef.purify (self : FixedVectorTypeRef) : IO FixedVectorType := do
  fixedVectorType (← (← self.getElementType).purify) (← self.getSize)

-- ## ScalableVectorType

/--
  A pure representation of an LLVM
  [ScalableVectorType](https://llvm.org/doxygen/classllvm_1_1ScalableVectorType.html).
-/
abbrev ScalableVectorType := BaseScalableVectorType «Type»
instance : Coe ScalableVectorType «Type» := ⟨Type.scalableVector⟩

/-- A scalable SIMD vector type of the given element type with the given minimum size. -/
def scalableVectorType (elemType : «Type») (minSize : UInt32) : ScalableVectorType :=
  BaseScalableVectorType.mk ⟨elemType, minSize⟩

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the configuration is valid.
-/
def ScalableVectorType.getRef (self : ScalableVectorType) : LlvmM ScalableVectorTypeRef := do
  FixedVectorTypeRef.get (← self.elementType.getRef) self.minSize

/-- Lift this reference to a pure `ArrayType`. -/
def ScalableVectorTypeRef.purify (self : ScalableVectorTypeRef) : IO ScalableVectorType := do
  scalableVectorType (← (← self.getElementType).purify) (← self.getMinSize)

--------------------------------------------------------------------------------
-- # Convenience functions for constructing PointerTypes
--------------------------------------------------------------------------------

protected abbrev Type.pointerType (self : «Type») :=
  pointerType self
protected abbrev IntegerType.pointerType (self : IntegerType) :=
  pointerType self
protected abbrev FunctionType.pointerType (self : FunctionType) :=
  pointerType self
protected abbrev PointerType.pointerType (self : PointerType) :=
  pointerType self
protected abbrev StructType.pointerType (self : StructType) :=
  pointerType self
protected abbrev ArrayType.pointerType (self : ArrayType) :=
  pointerType self
protected abbrev VectorType.pointerType (self : VectorType) :=
  pointerType self
protected abbrev FixedVectorType.pointerType (self : FixedVectorType) :=
  pointerType self
protected abbrev ScalableVectorType.pointerType (self : ScalableVectorType) :=
  pointerType self
