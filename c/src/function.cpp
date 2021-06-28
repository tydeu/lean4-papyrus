#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Function.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// Get the LLVM Function pointer wrapped in an object.
llvm::Function* toFunction(lean::object* funRef) {
    return llvm::cast<Function>(toValue(funRef));
}

// Get a reference to a newly created function.
extern "C" obj_res papyrus_create_function
(b_obj_arg typeRef, b_obj_arg nameObj, uint8 linkage, uint32 addrSpace, obj_arg /* w */)
{
    auto* fun = Function::Create(toFunctionType(typeRef),
      static_cast<GlobalValue::LinkageTypes>(linkage), addrSpace, string_to_ref(nameObj));
    return io_result_mk_ok(mk_value_ref(getTypeContext(typeRef), fun));
}

} // end namespace papyrus
