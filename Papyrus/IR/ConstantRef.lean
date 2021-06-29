import Papyrus.Context
import Papyrus.IR.ValueRef

namespace Papyrus

/--
  An external reference to the LLVM representation of a
  [Constant](https://llvm.org/doxygen/classllvm_1_1Constant.html).
-/
def ConstantRef := UserRef
