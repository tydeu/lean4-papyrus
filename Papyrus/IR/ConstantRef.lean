import Papyrus.Context
import Papyrus.IR.ValueRef

namespace Papyrus

/--
  A reference to an external LLVM
  [Constant](https://llvm.org/doxygen/classllvm_1_1Constant.html).
-/
structure ConstantRef extends UserRef
instance : Coe ConstantRef UserRef := ⟨(·.toUserRef)⟩
