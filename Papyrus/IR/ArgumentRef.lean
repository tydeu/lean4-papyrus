import Papyrus.Context
import Papyrus.IR.ValueRef

namespace Papyrus

/--
  A reference to an external LLVM
  [Argument](https://llvm.org/doxygen/classllvm_1_1Argument.html).
-/
structure ArgumentRef extends ValueRef where
  is_argument : toValueRef.valueKind = ValueKind.argument

instance : Coe ArgumentRef ValueRef := ⟨(·.toValueRef)⟩

namespace ArgumentRef

def cast (val : ValueRef) (h : val.valueKind = ValueKind.argument) : ArgumentRef :=
  {toValueRef := val, is_argument := h}
