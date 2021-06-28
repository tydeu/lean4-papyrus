#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Verifier.h>

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

// Get an array of references to the basic blocks of the given function.
extern "C" obj_res papyrus_function_get_basic_blocks(b_obj_arg funRef, obj_arg /* w */) {
    auto ctxRef = getBorrowedValueContext(funRef);
    auto& bbs = toFunction(funRef)->getBasicBlockList();
    lean_object* arr = lean::alloc_array(0, 8);
    for (BasicBlock& bb : bbs) {
        lean_inc_ref(ctxRef);
        arr = lean_array_push(arr, mk_value_ref(ctxRef, &bb));
    }
    return io_result_mk_ok(arr);
}

// Add the given instruction to the end of the given basic block.
extern "C" obj_res papyrus_function_append_basic_block
(b_obj_arg bbRef, b_obj_arg funRef, obj_arg /* w */)
{
    toFunction(funRef)->getBasicBlockList().push_back(toBasicBlock(bbRef));
    return io_result_mk_ok(box(0));
}

// Check the given function for errors (returns true if any errors are found).
extern "C" obj_res papyrus_function_verify(b_obj_arg funRef, obj_arg /* w */) {
    return io_result_mk_ok(box(llvm::verifyFunction(*toFunction(funRef))));
}

} // end namespace papyrus
