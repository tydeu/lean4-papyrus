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
// GetElementPtr instructions
//------------------------------------------------------------------------------

// Get the LLVM GetElementPtrInst pointer wrapped in an object.
GetElementPtrInst* toGetElementPtrInst(lean::object* instRef) {
	return llvm::cast<GetElementPtrInst>(toValue(instRef));
}

// Get a reference to a newly created `getelementptr` instruction.
extern "C" obj_res papyrus_getelementptr_inst_create
	(b_obj_arg typeRef, b_obj_arg ptrVal, b_obj_arg indicesObj,
		b_obj_arg nameObj, obj_arg /* w */)
{
	LEAN_ARRAY_TO_REF(Value*, toValue, indicesObj, indices);
	auto inst = GetElementPtrInst::Create(
		toType(typeRef), toValue(ptrVal), indices, refOfString(nameObj));
	return io_result_mk_ok(mkValueRef(copyLink(typeRef), inst));
}

// Get a reference to a newly created `getelementptr inbounds` instruction.
extern "C" obj_res papyrus_getelementptr_inst_create_inbounds
	(b_obj_arg typeRef, b_obj_arg ptrVal, b_obj_arg indicesObj,
		b_obj_arg nameObj, obj_arg /* w */)
{
	LEAN_ARRAY_TO_REF(Value*, toValue, indicesObj, indices);
	auto inst = GetElementPtrInst::CreateInBounds(
		toType(typeRef), toValue(ptrVal), indices, refOfString(nameObj));
	return io_result_mk_ok(mkValueRef(copyLink(typeRef), inst));
}

// Get a reference to the referenced GEP instruction's subject.
extern "C" obj_res papyrus_getelementptr_inst_get_pointer_operand
	(b_obj_arg instRef, obj_res /* w */)
{
	auto op = toGetElementPtrInst(instRef)->getPointerOperand();
	return io_result_mk_ok(mkValueRef(copyLink(instRef), op));
}

// Get an array of references to the referenced GEP instruction's indices.
extern "C" obj_res papyrus_getelementptr_inst_get_indices
	(b_obj_arg instRef, obj_res /* w */)
{
	auto link = borrowLink(instRef);
	auto is = toGetElementPtrInst(instRef)->indices();
	lean_object* arr = lean::alloc_array(0, 8);
	for (auto& i : is) {
		lean_inc_ref(link);
		arr = lean_array_push(arr, mkValueRef(link, i.get()));
	}
	return io_result_mk_ok(arr);
}

// Get whether the referenced GEP instruction has an `inbounds` flag.
extern "C" obj_res papyrus_getelementptr_inst_get_inbounds
	(b_obj_arg instRef, obj_res /* w */)
{
	return io_result_mk_ok(box(toGetElementPtrInst(instRef)->isInBounds()));
}

// Set whether the referenced GEP instruction has an `inbounds` flag.
extern "C" obj_res papyrus_getelementptr_inst_set_inbounds
	(uint8 inbounds, b_obj_arg instRef, obj_res /* w */)
{
	toGetElementPtrInst(instRef)->setIsInBounds(inbounds);
	return io_result_mk_ok(box(0));
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
