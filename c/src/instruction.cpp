#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Instructions.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// Get the LLVM Instruction pointer wrapped in an object.
llvm::Instruction* toInstruction(lean::object* instRef) {
    return llvm::cast<Instruction>(toValue(instRef));
}

//------------------------------------------------------------------------------
// Return instructions
//------------------------------------------------------------------------------

// Get the LLVM ReturnInst pointer wrapped in an object.
llvm::ReturnInst* toReturnInst(lean::object* instRef) {
    return llvm::cast<ReturnInst>(toValue(instRef));
}

// Get a reference to a newly created return instruction.
extern "C" obj_res papyrus_create_return_inst
(b_obj_arg retValObj, obj_arg ctxRef, obj_arg /* w */)
{
    llvm::Value* retVal = lean_is_scalar(retValObj) ? nullptr :
        toValue(lean_ctor_get(retValObj, 0));
    auto inst = ReturnInst::Create(*toLLVMContext(ctxRef), retVal);
    return io_result_mk_ok(mk_value_ref(ctxRef, inst));
}

// Get a reference to the value returned by the instruction.
extern "C" obj_res papyrus_return_inst_get_value(b_obj_arg instObj, obj_arg /* w */) {
    auto value = toReturnInst(instObj)->getReturnValue();
    lean::object* o = value == nullptr ? mk_option_none() :
        mk_option_some(mk_value_ref(getValueContext(instObj), value));
    return io_result_mk_ok(o);
}

} // end namespace papyrus
