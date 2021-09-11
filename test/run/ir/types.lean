import Papyrus

open Papyrus

def checkTypeRoundtrips (type : «Type») : IO PUnit :=
  LlvmM.run do
    let ref ← type.getRef
    let actual ← ref.purify
    unless type == actual do
      ref.dump
      IO.println s!"expected {repr type}, got {repr actual}"
      throw <| IO.userError "did not round trip"

macro tk:"#check_type" x:term : command => do
  Script.mkEvalAt tk <| ← ``(checkTypeRoundtrips $x)

#check_type voidType
#check_type labelType
#check_type metadataType
#check_type tokenType
#check_type x86MMXType
#check_type x86AMXType

#check_type halfType
#check_type bfloatType
#check_type floatType
#check_type doubleType
#check_type x86FP80Type
#check_type fp128Type
#check_type ppcFP128Type

#check_type integerType 100
#check_type functionType voidType #[int8Type.pointerType] true
#check_type pointerType fp128Type
#check_type structType "foo" #[integerType 24] true
#check_type arrayType halfType 6
#check_type vectorType int32Type 4 true
#check_type fixedVectorType doubleType 8
#check_type scalableVectorType int1Type 16
