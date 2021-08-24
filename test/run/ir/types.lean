import Papyrus

open Papyrus

def checkTypeRoundtrips (type : «Type») : IO PUnit :=
  LlvmM.run do
    unless type == (← (← type.getRef).purify) do
      throw <| IO.userError "did not round trip"

macro tk:"#verify" x:term : command => do
  Script.mkEvalAt tk <| ← ``(checkTypeRoundtrips $x)

#verify voidType
#verify labelType
#verify metadataType
#verify tokenType
#verify x86MMXType
#verify x86AMXType

#verify halfType
#verify bfloatType
#verify floatType
#verify doubleType
#verify x86FP80Type
#verify fp128Type
#verify ppcFP128Type

#verify integerType 100
#verify functionType voidType #[int8Type.pointerType] true
#verify pointerType fp128Type
#verify structType "foo'" #[integerType 24] true
#verify arrayType halfType 6
#verify vectorType int32Type 4 true
#verify fixedVectorType doubleType 8
#verify scalableVectorType int1Type 16
