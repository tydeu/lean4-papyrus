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
// Return
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

//------------------------------------------------------------------------------
// Load
//------------------------------------------------------------------------------

// Get the LLVM LoadInst pointer wrapped in an object.
LoadInst* toLoadInst(lean::object* instRef) {
	return llvm::cast<LoadInst>(toValue(instRef));
}

// Get a reference to a newly created `load` instruction.
extern "C" obj_res papyrus_load_inst_create
	(b_obj_arg typeRef, b_obj_arg ptrValRef, b_obj_arg nameObj, uint8 isVolatile,
		uint8 align, uint8 order, uint32 ssid, obj_arg /* w */)
{
	auto inst = new LoadInst(toType(typeRef), toValue(ptrValRef), refOfString(nameObj),
		isVolatile, Align(uint64_t(1) << align), AtomicOrdering(order), ssid);
	return io_result_mk_ok(mkValueRef(copyLink(typeRef), inst));
}

// Get a reference to the given load instruction's pointer operand.
extern "C" obj_res papyrus_load_inst_get_pointer_operand
	(b_obj_arg instRef, obj_res /* w */)
{
	auto op = toLoadInst(instRef)->getPointerOperand();
	return io_result_mk_ok(mkValueRef(copyLink(instRef), op));
}

// Get whether the given load instruction is volatile.
extern "C" obj_res papyrus_load_inst_get_volatile
	(b_obj_arg instRef, obj_arg /* w */)
{
	return io_result_mk_ok(box(toLoadInst(instRef)->isVolatile()));
}

// Set whether the given load instruction is volatile.
extern "C" obj_res papyrus_load_inst_set_volatile
	(uint8 isVolatile, b_obj_arg instRef, obj_arg /* w */)
{
	toLoadInst(instRef)->setVolatile(isVolatile);
	return io_result_mk_ok(box(0));
}

// Get the alignment of the given load instruction.
extern "C" obj_res papyrus_load_inst_get_align
	(b_obj_arg instRef, obj_arg /* w */)
{
	return io_result_mk_ok(box(Log2(toLoadInst(instRef)->getAlign())));
}

// Set the alignment of the given load instruction.
extern "C" obj_res papyrus_load_inst_set_align
	(uint8 align, b_obj_arg instRef, obj_arg /* w */)
{
	toLoadInst(instRef)->setAlignment(Align(uint64_t(1) << align));
	return io_result_mk_ok(box(0));
}

// Get the ordering constraint of the given load instruction.
extern "C" obj_res papyrus_load_inst_get_ordering
	(b_obj_arg instRef, obj_arg /* w */)
{
	return io_result_mk_ok(box(static_cast<uint8>(toLoadInst(instRef)->getOrdering())));
}

// Set the ordering constraint of the given load instruction.
extern "C" obj_res papyrus_load_inst_set_ordering
	(uint8 order, b_obj_arg instRef, obj_arg /* w */)
{
	toLoadInst(instRef)->setOrdering(AtomicOrdering(order));
	return io_result_mk_ok(box(0));
}

// Get the synchronization scope ID of the given load instruction.
extern "C" obj_res papyrus_load_inst_get_sync_scope_id
	(b_obj_arg instRef, obj_arg /* w */)
{
	return io_result_mk_ok(box_uint32(toLoadInst(instRef)->getSyncScopeID()));
}

// Set the synchronization scope ID of the given load instruction.
extern "C" obj_res papyrus_load_inst_set_sync_scope_id
	(uint32 ssid, b_obj_arg instRef, obj_arg /* w */)
{
	toLoadInst(instRef)->setSyncScopeID(ssid);
	return io_result_mk_ok(box(0));
}

// Set the ordering constraint and
// synchronization scope ID  of the given load instruction.
extern "C" obj_res papyrus_load_inst_set_atomic
	(uint8 order, uint32 ssid, b_obj_arg instRef, obj_arg /* w */)
{
	toLoadInst(instRef)->setAtomic(AtomicOrdering(order), ssid);
	return io_result_mk_ok(box(0));
}

//------------------------------------------------------------------------------
// Store
//------------------------------------------------------------------------------

// Get the LLVM StoreInst pointer wrapped in an object.
StoreInst* toStoreInst(lean::object* instRef) {
	return llvm::cast<StoreInst>(toValue(instRef));
}

// Get a reference to a newly created `store` instruction.
extern "C" obj_res papyrus_store_inst_create
	(b_obj_arg valRef, b_obj_arg ptrValRef, uint8 isVolatile,
		uint8 align, uint8 order, uint32 ssid, obj_arg /* w */)
{
	auto inst = new StoreInst(toValue(valRef), toValue(ptrValRef),
		isVolatile, Align(uint64_t(1) << align), AtomicOrdering(order), ssid);
	return io_result_mk_ok(mkValueRef(copyLink(valRef), inst));
}

// Get a reference to value the given store instruction is storing.
extern "C" obj_res papyrus_store_inst_get_value_operand
	(b_obj_arg instRef, obj_res /* w */)
{
	auto op = toStoreInst(instRef)->getValueOperand();
	return io_result_mk_ok(mkValueRef(copyLink(instRef), op));
}

// Get a reference to the given store instruction's pointer operand.
extern "C" obj_res papyrus_store_inst_get_pointer_operand
	(b_obj_arg instRef, obj_res /* w */)
{
	auto op = toStoreInst(instRef)->getPointerOperand();
	return io_result_mk_ok(mkValueRef(copyLink(instRef), op));
}

// Get whether the given store instruction is volatile.
extern "C" obj_res papyrus_store_inst_get_volatile
	(b_obj_arg instRef, obj_arg /* w */)
{
	return io_result_mk_ok(box(toStoreInst(instRef)->isVolatile()));
}

// Set whether the given store instruction is volatile.
extern "C" obj_res papyrus_store_inst_set_volatile
	(uint8 isVolatile, b_obj_arg instRef, obj_arg /* w */)
{
	toStoreInst(instRef)->setVolatile(isVolatile);
	return io_result_mk_ok(box(0));
}

// Get the alignment of the given store instruction.
extern "C" obj_res papyrus_store_inst_get_align
	(b_obj_arg instRef, obj_arg /* w */)
{
	return io_result_mk_ok(box(Log2(toStoreInst(instRef)->getAlign())));
}

// Set the alignment of the given store instruction.
extern "C" obj_res papyrus_store_inst_set_align
	(uint8 align, b_obj_arg instRef, obj_arg /* w */)
{
	toStoreInst(instRef)->setAlignment(Align(uint64_t(1) << align));
	return io_result_mk_ok(box(0));
}

// Get the ordering constraint of the given store instruction.
extern "C" obj_res papyrus_store_inst_get_ordering
	(b_obj_arg instRef, obj_arg /* w */)
{
	return io_result_mk_ok(box(static_cast<uint8>(toStoreInst(instRef)->getOrdering())));
}

// Set the ordering constraint of the given store instruction.
extern "C" obj_res papyrus_store_inst_set_ordering
	(uint8 order, b_obj_arg instRef, obj_arg /* w */)
{
	toStoreInst(instRef)->setOrdering(AtomicOrdering(order));
	return io_result_mk_ok(box(0));
}

// Get the synchronization scope ID of the given store instruction.
extern "C" obj_res papyrus_store_inst_get_sync_scope_id
	(b_obj_arg instRef, obj_arg /* w */)
{
	return io_result_mk_ok(box_uint32(toStoreInst(instRef)->getSyncScopeID()));
}

// Set the synchronization scope ID of the given store instruction.
extern "C" obj_res papyrus_store_inst_set_sync_scope_id
	(uint32 ssid, b_obj_arg instRef, obj_arg /* w */)
{
	toStoreInst(instRef)->setSyncScopeID(ssid);
	return io_result_mk_ok(box(0));
}

// Set the ordering constraint and
// synchronization scope ID  of the given store instruction.
extern "C" obj_res papyrus_store_inst_set_atomic
	(uint8 order, uint32 ssid, b_obj_arg instRef, obj_arg /* w */)
{
	toStoreInst(instRef)->setAtomic(AtomicOrdering(order), ssid);
	return io_result_mk_ok(box(0));
}

//------------------------------------------------------------------------------
// GetElementPtr
//------------------------------------------------------------------------------

// Get the LLVM GetElementPtrInst pointer wrapped in an object.
GetElementPtrInst* toGetElementPtrInst(lean::object* instRef) {
	return llvm::cast<GetElementPtrInst>(toValue(instRef));
}

// Get a reference to a newly created `getelementptr` instruction.
extern "C" obj_res papyrus_getelementptr_inst_create
	(b_obj_arg typeRef, b_obj_arg ptrValRef, b_obj_arg indicesObj,
		b_obj_arg nameObj, obj_arg /* w */)
{
	LEAN_ARRAY_TO_REF(Value*, toValue, indicesObj, indices);
	auto inst = GetElementPtrInst::Create(
		toType(typeRef), toValue(ptrValRef), indices, refOfString(nameObj));
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
// Call
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

} // end namespace papyrus
