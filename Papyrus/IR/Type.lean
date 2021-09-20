import Papyrus.IR.TypeID
import Papyrus.IR.TypeRefs
import Papyrus.IR.TypeBases
import Papyrus.IR.AddressSpace

namespace Papyrus

-- # The LLVM Type Inductive

/--
  A pure representation of an LLVM
  [Type](https://llvm.org/doxygen/classllvm_1_1Type.html).
-/
inductive «Type»
| half
| bfloat
| float
| double
| x86FP80
| fp128
| ppcFP128
| void
| label
| metadata
| x86MMX
| x86AMX
| token
| integer (type : IntegerType)
| function (type : BaseFunctionType «Type»)
| pointer (type : BasePointerType «Type»)
| struct (type : BaseStructType «Type»)
| array (type : BaseArrayType «Type»)
| fixedVector (type : BaseFixedVectorType «Type»)
| scalableVector (type : BaseScalableVectorType «Type»)
deriving BEq, Repr

/-- The LLVM type ID of this type. -/
@[extern "lean_ptr_tag"]
def Type.typeID : (self : @& «Type») → TypeID
| half => TypeID.half
| bfloat => TypeID.bfloat
| float => TypeID.float
| double => TypeID.double
| x86FP80 => TypeID.x86FP80
| fp128 => TypeID.fp128
| ppcFP128 => TypeID.ppcFP128
| void => TypeID.void
| label => TypeID.label
| metadata => TypeID.metadata
| x86MMX => TypeID.x86MMX
| x86AMX => TypeID.x86AMX
| token => TypeID.token
| integer .. => TypeID.integer
| function .. => TypeID.function
| pointer .. => TypeID.pointer
| struct .. => TypeID.struct
| array .. => TypeID.array
| fixedVector .. => TypeID.fixedVector
| scalableVector .. => TypeID.scalableVector

-- # Type -> TypeRef

open BaseStructType in
/-- Get a reference to an external LLVM representation of this type. -/
partial def Type.getRef : (type : «Type») → LlvmM TypeRef
| half => HalfTypeRef.get
| bfloat => BFloatTypeRef.get
| float => FloatTypeRef.get
| double => DoubleTypeRef.get
| x86FP80 => X86FP80TypeRef.get
| fp128 => FP128TypeRef.get
| ppcFP128 => PPCFP128TypeRef.get
| void => VoidTypeRef.get
| label => LabelTypeRef.get
| metadata => MetadataTypeRef.get
| x86MMX => X86MMXTypeRef.get
| x86AMX => X86AMXTypeRef.get
| token => TokenTypeRef.get
| integer ⟨bitWidth⟩ =>
  IntegerTypeRef.get bitWidth
| function ⟨retType, paramTypes, isVarArg⟩ => do
  FunctionTypeRef.get (← getRef retType) (← paramTypes.mapM getRef) isVarArg
| pointer ⟨pointeeType, addrSpace⟩ => do
  PointerTypeRef.get (← getRef pointeeType) addrSpace
| struct type =>
  match type with
  | literal ⟨elemTypes, isPacked⟩ => do
    LiteralStructTypeRef.get (← elemTypes.mapM getRef) isPacked
  | complete name ⟨elemTypes, isPacked⟩ => do
    IdentifiedStructTypeRef.getOrCreate name (← elemTypes.mapM getRef) isPacked
  | opaque name =>
    IdentifiedStructTypeRef.getOrCreateOpaque name
| array ⟨elemType, numElems⟩ => do
  ArrayTypeRef.get (← getRef elemType) numElems
| fixedVector ⟨elemType, numElems⟩ => do
  FixedVectorTypeRef.get (← getRef elemType) numElems
| scalableVector ⟨elemType, minNumElems⟩ => do
  ScalableVectorTypeRef.get (← getRef elemType) minNumElems

-- # TypeRef -> Type

open TypeID in
/-- Lift this reference to a pure `Type`. -/
partial def TypeRef.purify (self : TypeRef) : IO «Type» := do
  match h:self.typeID with
  | half => Type.half
  | bfloat => Type.bfloat
  | float => Type.float
  | double => Type.double
  | x86FP80 => Type.x86FP80
  | fp128 => Type.fp128
  | ppcFP128 => Type.ppcFP128
  | void => Type.void
  | label => Type.label
  | metadata => Type.metadata
  | x86MMX => Type.x86MMX
  | x86AMX => Type.x86AMX
  | token => Type.token
  | integer =>
    let self := IntegerTypeRef.cast self h
    Type.integer ⟨← self.getBitWidth⟩
  | function =>
    let self := FunctionTypeRef.cast self h
    Type.function ⟨← purify <| ← self.getReturnType,
      ← Array.mapM purify <| ← self.getParameterTypes, ← self.isVarArg⟩
  | pointer =>
    let self := PointerTypeRef.cast self h
    Type.pointer ⟨← purify <| ← self.getPointeeType, ← self.getAddressSpace⟩
  | struct =>
    let self := StructTypeRef.cast self h
    if h : self.isLiteral then
      let self := LiteralStructTypeRef.cast self h
      Type.struct <| BaseStructType.literal
        ⟨← Array.mapM purify <| ← self.getElementTypes, ← self.isPacked⟩
    else
      let self := IdentifiedStructTypeRef.cast self h
      if (← self.isOpaque) then
        Type.struct <| BaseStructType.opaque (← self.getName)
      else
        Type.struct <| BaseStructType.complete (← self.getName)
          ⟨← Array.mapM purify <| ← self.getElementTypes, ← self.isPacked⟩
  | array =>
    let self := ArrayTypeRef.cast self h
    Type.array ⟨← purify <| ← self.getElementType, ← self.getSize⟩
  | fixedVector =>
    let self := FixedVectorTypeRef.cast self h
    Type.fixedVector ⟨← purify <| ← self.getElementType, ← self.getSize⟩
  | scalableVector =>
    let self := ScalableVectorTypeRef.cast self h
    Type.scalableVector ⟨← purify <| ← self.getElementType, ← self.getMinSize⟩
