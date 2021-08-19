#include "papyrus.h"
#include "papyrus_ffi.h"

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
// Call instructions
//------------------------------------------------------------------------------

// Get a reference to a newly created call instruction.
extern "C" obj_res papyrus_call_inst_create
(b_obj_arg typeRef, b_obj_arg funVal, b_obj_arg argsObj,
	b_obj_arg nameObj, obj_arg /* w */)
{
	LEAN_ARRAY_TO_REF(Value*, toValue, argsObj, args);
	auto i = CallInst::Create(toFunctionType(typeRef), toValue(funVal), args,
		refOfString(nameObj));
	return io_result_mk_ok(mkValueRef(copyLink(typeRef), i));
}

//------------------------------------------------------------------------------
// Return instructions
//------------------------------------------------------------------------------

// Get the LLVM ReturnInst pointer wrapped in an object.
ReturnInst* toReturnInst(lean::object* instRef) {
	return llvm::cast<ReturnInst>(toValue(instRef));
}

// Get a reference to a newly created return instruction.
extern "C" obj_res papyrus_return_inst_create
(b_obj_arg retValObj, obj_arg ctxRef, obj_arg /* w */)
{
	auto inst = ReturnInst::Create(*toLLVMContext(ctxRef), toValue(retValObj));
	return io_result_mk_ok(mkValueRef(ctxRef, inst));
}

// Get a reference to a newly created void return instruction.
extern "C" obj_res papyrus_return_inst_create_void(obj_arg ctxRef, obj_arg /* w */) {
	auto inst = ReturnInst::Create(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkValueRef(ctxRef, inst));
}

// Get a reference to the value returned by the instruction.
extern "C" obj_res papyrus_return_inst_get_value(b_obj_arg instObj, obj_arg /* w */) {
	auto value = toReturnInst(instObj)->getReturnValue();
	auto obj = value == nullptr ? mk_option_none() :
		mk_option_some(mkValueRef(getValueContext(instObj), value));
	return io_result_mk_ok(obj);
}

} // end namespace papyrus
