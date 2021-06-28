import Papyrus.IR.Types.Primitive
import Papyrus.IR.Types.Integer
import Papyrus.IR.Types.Function
import Papyrus.IR.Types.Struct
import Papyrus.IR.Types.Pointer
import Papyrus.IR.Types.Array
import Papyrus.IR.Types.Vector

namespace Papyrus

--------------------------------------------------------------------------------
-- Convience Methods
--------------------------------------------------------------------------------

-- # Pointer Types

def HalfType.pointerType (self : HalfType) :=
  Papyrus.pointerType self
def BFloatType.pointerType (self : BFloatType) :=
  Papyrus.pointerType self
def FloatType.pointerType (self : FloatType) :=
  Papyrus.pointerType self
def DoubleType.pointerType (self : DoubleType) :=
  Papyrus.pointerType self
def X86FP80Type.pointerType (self : X86FP80Type) :=
  Papyrus.pointerType self
def FP128Type.pointerType (self : FP128Type) :=
  Papyrus.pointerType self
def PPCFP128Type.pointerType (self : PPCFP128Type) :=
  Papyrus.pointerType self
def IntegerType.pointerType {numBits} (self : IntegerType numBits) :=
  Papyrus.pointerType self
def FunctionType.pointerType {varArgs} (self : FunctionType α β varArgs) :=
  Papyrus.pointerType self
def CompleteStructType.pointerType {name packed} (self : CompleteStructType name α packed) :=
  Papyrus.pointerType self
def OpaqueStructType.pointerType {name} (self : OpaqueStructType name) :=
  Papyrus.pointerType self
def LiteralStructType.pointerType {packed} (self : LiteralStructType α packed) :=
  Papyrus.pointerType self
def PointerType.pointerType {addrSpace} (self : PointerType α addrSpace) :=
  Papyrus.pointerType self
def ArrayType.pointerType {numElems} (self : ArrayType α numElems) :=
  Papyrus.pointerType self
def VectorType.pointerType {elemQuant scalable} (self : VectorType α elemQuant scalable) :=
  Papyrus.pointerType self
