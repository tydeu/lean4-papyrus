import Papyrus.Types.TypeID
import Papyrus.Types.TypeRef
import Papyrus.Types.Primitive
import Papyrus.Types.Integer
import Papyrus.Types.Pointer
import Papyrus.Types.Array
import Papyrus.Types.Vector

namespace Papyrus

--------------------------------------------------------------------------------
-- Convience Methods
--------------------------------------------------------------------------------

-- # Pointer Types

def HalfType.pointerType (self : HalfType) := PointerType.mk' self
def BFloatType.pointerType (self : BFloatType) := PointerType.mk' self
def FloatType.pointerType (self : FloatType) := PointerType.mk' self
def DoubleType.pointerType (self : DoubleType) := PointerType.mk' self
def X86FP80Type.pointerType (self : X86FP80Type) := PointerType.mk' self
def FP128Type.pointerType (self : FP128Type) := PointerType.mk' self
def PPCFP128Type.pointerType (self : PPCFP128Type) := PointerType.mk' self

def IntegerType.pointerType {numBits} (self : IntegerType numBits) :=
  PointerType.mk' self
def PointerType.pointerType {addrSpace} (self : PointerType α addrSpace) :=
  PointerType.mk' self
def ArrayType.pointerType {numElems} (self : ArrayType α numElems) :=
  PointerType.mk' self
