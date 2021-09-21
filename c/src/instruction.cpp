#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/IR/Instructions.h>

using namespace llvm;

namespace papyrus {

// Get the LLVM Instruction pointer wrapped in an object.
llvm::Instruction* toInstruction(lean_object* instRef) {
	return llvm::cast<Instruction>(toValue(instRef));
}

//------------------------------------------------------------------------------
// Return
//------------------------------------------------------------------------------

// Get the LLVM ReturnInst pointer wrapped in an object.
ReturnInst* toReturnInst(lean_object* instRef) {
	return llvm::cast<ReturnInst>(toValue(instRef));
}

// Get a reference to a newly created return instruction.
extern "C" lean_obj_res papyrus_return_inst_create
(b_lean_obj_res retValObj, lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto inst = ReturnInst::Create(*toLLVMContext(ctxRef), toValue(retValObj));
	return lean_io_result_mk_ok(mkValueRef(ctxRef, inst));
}

// Get a reference to a newly created void return instruction.
extern "C" lean_obj_res papyrus_return_inst_create_void(lean_obj_arg ctxRef, lean_obj_arg /* w */) {
	auto inst = ReturnInst::Create(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkValueRef(ctxRef, inst));
}

// Get a reference to the value returned by the instruction.
extern "C" lean_obj_res papyrus_return_inst_get_value(b_lean_obj_res instObj, lean_obj_arg /* w */) {
	auto value = toReturnInst(instObj)->getReturnValue();
	auto obj = value == nullptr ? lean_box(0) :
		mkSome(mkValueRef(getValueContext(instObj), value));
	return lean_io_result_mk_ok(obj);
}

//------------------------------------------------------------------------------
// Branch
//------------------------------------------------------------------------------

// Get the LLVM BranchInst pointer wrapped in an object.
BranchInst* toBranchInst(lean_object* instRef) {
	return llvm::cast<BranchInst>(toValue(instRef));
}

// Get a reference to a newly created conditional `br` instruction.
extern "C" lean_obj_res papyrus_branch_inst_create
	(b_lean_obj_res ifTrueRef, b_lean_obj_res ifFalseRef, b_lean_obj_res condRef, lean_obj_arg /* w */)
{
	auto inst = BranchInst::Create(
			toBasicBlock(ifTrueRef), toBasicBlock(ifFalseRef), toValue(condRef));
	return lean_io_result_mk_ok(mkValueRef(copyLink(condRef), inst));
}

// Get a reference to a newly created unconditional `br` instruction.
extern "C" lean_obj_res papyrus_branch_inst_create_jump
	(b_lean_obj_res bbRef, lean_obj_arg /* w */)
{
	auto inst = BranchInst::Create(toBasicBlock(bbRef));
	return lean_io_result_mk_ok(mkValueRef(copyLink(bbRef), inst));
}

// Get whether the branch instruction is conditional.
// As this property is immutable, we don't need to wrap it in IO.
extern "C" uint8_t papyrus_branch_inst_is_conditional
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	return toBranchInst(instRef)->isConditional();
}

// Get a reference to the condition of a conditional branch instruction.
extern "C" lean_obj_res papyrus_branch_inst_get_condition
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	auto cond = toBranchInst(instRef)->getCondition();
	return lean_io_result_mk_ok(mkValueRef(copyLink(instRef), cond));
}

// Set the condition of a conditional branch instruction.
extern "C" lean_obj_res papyrus_branch_inst_set_condition
	(b_lean_obj_res condRef, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toBranchInst(instRef)->setCondition(toValue(condRef));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get an array of references to the given branch instructions successors.
extern "C" lean_obj_res papyrus_branch_inst_get_successors
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	auto inst = toBranchInst(instRef);
	auto isConditional = inst->isConditional();
	auto numSuccessors = 1+isConditional;
	lean_object* arr = lean_alloc_array(numSuccessors, numSuccessors);
	lean_array_object* arrObj  = (lean_array_object*)(arr);
	arrObj->m_data[0] = mkValueRef(copyLink(instRef), inst->getSuccessor(0));
	if (isConditional) {
		arrObj->m_data[1] = mkValueRef(copyLink(instRef), inst->getSuccessor(1));
	}
	return lean_io_result_mk_ok(arr);
}

// Get a reference to the first successor of a branch instruction.
extern "C" lean_obj_res papyrus_branch_inst_get_successor0
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	auto bb = toBranchInst(instRef)->getSuccessor(0);
	return lean_io_result_mk_ok(mkValueRef(copyLink(instRef), bb));
}

// Set the first successor of a branch instruction.
extern "C" lean_obj_res papyrus_branch_inst_set_successor0
	(b_lean_obj_res bbRef, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toBranchInst(instRef)->setSuccessor(0, toBasicBlock(bbRef));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get a reference to the second successor of a (conditional) branch instruction.
extern "C" lean_obj_res papyrus_branch_inst_get_successor1
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	auto bb = toBranchInst(instRef)->getSuccessor(1);
	return lean_io_result_mk_ok(mkValueRef(copyLink(instRef), bb));
}

// Set the first successor of a  (conditional) branch instruction.
extern "C" lean_obj_res papyrus_branch_inst_set_successor1
	(b_lean_obj_res bbRef, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toBranchInst(instRef)->setSuccessor(1, toBasicBlock(bbRef));
	return lean_io_result_mk_ok(lean_box(0));
}

// Swap the successors of a conditional branch instruction.
extern "C" lean_obj_res papyrus_branch_inst_swap_successors
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toBranchInst(instRef)->swapSuccessors();
	return lean_io_result_mk_ok(lean_box(0));
}

//------------------------------------------------------------------------------
// Load
//------------------------------------------------------------------------------

// Get the LLVM LoadInst pointer wrapped in an object.
LoadInst* toLoadInst(lean_object* instRef) {
	return llvm::cast<LoadInst>(toValue(instRef));
}

// Get a reference to a newly created `load` instruction.
extern "C" lean_obj_res papyrus_load_inst_create
	(b_lean_obj_res typeRef, b_lean_obj_res ptrValRef, b_lean_obj_res nameObj, uint8_t isVolatile,
		uint8_t align, uint8_t order, uint32_t ssid, lean_obj_arg /* w */)
{
	auto inst = new LoadInst(toType(typeRef), toValue(ptrValRef), refOfString(nameObj),
		isVolatile, Align(uint64_t(1) << align), AtomicOrdering(order), ssid);
	return lean_io_result_mk_ok(mkValueRef(copyLink(typeRef), inst));
}

// Get a reference to the given load instruction's pointer operand.
extern "C" lean_obj_res papyrus_load_inst_get_pointer_operand
	(b_lean_obj_res instRef, lean_obj_res /* w */)
{
	auto op = toLoadInst(instRef)->getPointerOperand();
	return lean_io_result_mk_ok(mkValueRef(copyLink(instRef), op));
}

// Get whether the given load instruction is volatile.
extern "C" lean_obj_res papyrus_load_inst_get_volatile
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toLoadInst(instRef)->isVolatile()));
}

// Set whether the given load instruction is volatile.
extern "C" lean_obj_res papyrus_load_inst_set_volatile
	(uint8_t isVolatile, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toLoadInst(instRef)->setVolatile(isVolatile);
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the alignment of the given load instruction.
extern "C" lean_obj_res papyrus_load_inst_get_align
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(Log2(toLoadInst(instRef)->getAlign())));
}

// Set the alignment of the given load instruction.
extern "C" lean_obj_res papyrus_load_inst_set_align
	(uint8_t align, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toLoadInst(instRef)->setAlignment(Align(uint64_t(1) << align));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the ordering constraint of the given load instruction.
extern "C" lean_obj_res papyrus_load_inst_get_ordering
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(static_cast<uint8_t>(toLoadInst(instRef)->getOrdering())));
}

// Set the ordering constraint of the given load instruction.
extern "C" lean_obj_res papyrus_load_inst_set_ordering
	(uint8_t order, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toLoadInst(instRef)->setOrdering(AtomicOrdering(order));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the synchronization scope ID of the given load instruction.
extern "C" lean_obj_res papyrus_load_inst_get_sync_scope_id
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box_uint32(toLoadInst(instRef)->getSyncScopeID()));
}

// Set the synchronization scope ID of the given load instruction.
extern "C" lean_obj_res papyrus_load_inst_set_sync_scope_id
	(uint32_t ssid, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toLoadInst(instRef)->setSyncScopeID(ssid);
	return lean_io_result_mk_ok(lean_box(0));
}

// Set the ordering constraint and
// synchronization scope ID  of the given load instruction.
extern "C" lean_obj_res papyrus_load_inst_set_atomic
	(uint8_t order, uint32_t ssid, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toLoadInst(instRef)->setAtomic(AtomicOrdering(order), ssid);
	return lean_io_result_mk_ok(lean_box(0));
}

//------------------------------------------------------------------------------
// Store
//------------------------------------------------------------------------------

// Get the LLVM StoreInst pointer wrapped in an object.
StoreInst* toStoreInst(lean_object* instRef) {
	return llvm::cast<StoreInst>(toValue(instRef));
}

// Get a reference to a newly created `store` instruction.
extern "C" lean_obj_res papyrus_store_inst_create
	(b_lean_obj_res valRef, b_lean_obj_res ptrValRef, uint8_t isVolatile,
		uint8_t align, uint8_t order, uint32_t ssid, lean_obj_arg /* w */)
{
	auto inst = new StoreInst(toValue(valRef), toValue(ptrValRef),
		isVolatile, Align(uint64_t(1) << align), AtomicOrdering(order), ssid);
	return lean_io_result_mk_ok(mkValueRef(copyLink(valRef), inst));
}

// Get a reference to value the given store instruction is storing.
extern "C" lean_obj_res papyrus_store_inst_get_value_operand
	(b_lean_obj_res instRef, lean_obj_res /* w */)
{
	auto op = toStoreInst(instRef)->getValueOperand();
	return lean_io_result_mk_ok(mkValueRef(copyLink(instRef), op));
}

// Get a reference to the given store instruction's pointer operand.
extern "C" lean_obj_res papyrus_store_inst_get_pointer_operand
	(b_lean_obj_res instRef, lean_obj_res /* w */)
{
	auto op = toStoreInst(instRef)->getPointerOperand();
	return lean_io_result_mk_ok(mkValueRef(copyLink(instRef), op));
}

// Get whether the given store instruction is volatile.
extern "C" lean_obj_res papyrus_store_inst_get_volatile
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toStoreInst(instRef)->isVolatile()));
}

// Set whether the given store instruction is volatile.
extern "C" lean_obj_res papyrus_store_inst_set_volatile
	(uint8_t isVolatile, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toStoreInst(instRef)->setVolatile(isVolatile);
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the alignment of the given store instruction.
extern "C" lean_obj_res papyrus_store_inst_get_align
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(Log2(toStoreInst(instRef)->getAlign())));
}

// Set the alignment of the given store instruction.
extern "C" lean_obj_res papyrus_store_inst_set_align
	(uint8_t align, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toStoreInst(instRef)->setAlignment(Align(uint64_t(1) << align));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the ordering constraint of the given store instruction.
extern "C" lean_obj_res papyrus_store_inst_get_ordering
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(static_cast<uint8_t>(toStoreInst(instRef)->getOrdering())));
}

// Set the ordering constraint of the given store instruction.
extern "C" lean_obj_res papyrus_store_inst_set_ordering
	(uint8_t order, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toStoreInst(instRef)->setOrdering(AtomicOrdering(order));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the synchronization scope ID of the given store instruction.
extern "C" lean_obj_res papyrus_store_inst_get_sync_scope_id
	(b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box_uint32(toStoreInst(instRef)->getSyncScopeID()));
}

// Set the synchronization scope ID of the given store instruction.
extern "C" lean_obj_res papyrus_store_inst_set_sync_scope_id
	(uint32_t ssid, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toStoreInst(instRef)->setSyncScopeID(ssid);
	return lean_io_result_mk_ok(lean_box(0));
}

// Set the ordering constraint and
// synchronization scope ID  of the given store instruction.
extern "C" lean_obj_res papyrus_store_inst_set_atomic
	(uint8_t order, uint32_t ssid, b_lean_obj_res instRef, lean_obj_arg /* w */)
{
	toStoreInst(instRef)->setAtomic(AtomicOrdering(order), ssid);
	return lean_io_result_mk_ok(lean_box(0));
}

//------------------------------------------------------------------------------
// GetElementPtr
//------------------------------------------------------------------------------

// Get the LLVM GetElementPtrInst pointer wrapped in an object.
GetElementPtrInst* toGetElementPtrInst(lean_object* instRef) {
	return llvm::cast<GetElementPtrInst>(toValue(instRef));
}

// Get a reference to a newly created `getelementptr` instruction.
extern "C" lean_obj_res papyrus_getelementptr_inst_create
	(b_lean_obj_res typeRef, b_lean_obj_res ptrValRef, b_lean_obj_res indicesObj,
		b_lean_obj_res nameObj, lean_obj_arg /* w */)
{
	LEAN_ARRAY_TO_REF(Value*, toValue, indicesObj, indices);
	auto inst = GetElementPtrInst::Create(
		toType(typeRef), toValue(ptrValRef), indices, refOfString(nameObj));
	return lean_io_result_mk_ok(mkValueRef(copyLink(typeRef), inst));
}

// Get a reference to a newly created `getelementptr inbounds` instruction.
extern "C" lean_obj_res papyrus_getelementptr_inst_create_inbounds
	(b_lean_obj_res typeRef, b_lean_obj_res ptrVal, b_lean_obj_res indicesObj,
		b_lean_obj_res nameObj, lean_obj_arg /* w */)
{
	LEAN_ARRAY_TO_REF(Value*, toValue, indicesObj, indices);
	auto inst = GetElementPtrInst::CreateInBounds(
		toType(typeRef), toValue(ptrVal), indices, refOfString(nameObj));
	return lean_io_result_mk_ok(mkValueRef(copyLink(typeRef), inst));
}

// Get a reference to the referenced GEP instruction's subject.
extern "C" lean_obj_res papyrus_getelementptr_inst_get_pointer_operand
	(b_lean_obj_res instRef, lean_obj_res /* w */)
{
	auto op = toGetElementPtrInst(instRef)->getPointerOperand();
	return lean_io_result_mk_ok(mkValueRef(copyLink(instRef), op));
}

// Get an array of references to the referenced GEP instruction's indices.
extern "C" lean_obj_res papyrus_getelementptr_inst_get_indices
	(b_lean_obj_res instRef, lean_obj_res /* w */)
{
	auto link = borrowLink(instRef);
	auto is = toGetElementPtrInst(instRef)->indices();
	lean_object* arr = lean_alloc_array(0, PAPYRUS_DEFAULT_ARRAY_CAPCITY);
	for (auto& i : is) {
		lean_inc_ref(link);
		arr = lean_array_push(arr, mkValueRef(link, i.get()));
	}
	return lean_io_result_mk_ok(arr);
}

// Get whether the referenced GEP instruction has an `inbounds` flag.
extern "C" lean_obj_res papyrus_getelementptr_inst_get_inbounds
	(b_lean_obj_res instRef, lean_obj_res /* w */)
{
	return lean_io_result_mk_ok(lean_box(toGetElementPtrInst(instRef)->isInBounds()));
}

// Set whether the referenced GEP instruction has an `inbounds` flag.
extern "C" lean_obj_res papyrus_getelementptr_inst_set_inbounds
	(uint8_t inbounds, b_lean_obj_res instRef, lean_obj_res /* w */)
{
	toGetElementPtrInst(instRef)->setIsInBounds(inbounds);
	return lean_io_result_mk_ok(lean_box(0));
}

//------------------------------------------------------------------------------
// Call
//------------------------------------------------------------------------------

// Get a reference to a newly created call instruction.
extern "C" lean_obj_res papyrus_call_inst_create
	(b_lean_obj_res typeRef, b_lean_obj_res funVal, b_lean_obj_res argsObj,
		b_lean_obj_res nameObj, lean_obj_arg /* w */)
{
	LEAN_ARRAY_TO_REF(Value*, toValue, argsObj, args);
	auto i = CallInst::Create(toFunctionType(typeRef), toValue(funVal), args,
		refOfString(nameObj));
	return lean_io_result_mk_ok(mkValueRef(copyLink(typeRef), i));
}

//------------------------------------------------------------------------------
// Binary Operator
//------------------------------------------------------------------------------
extern "C" lean_obj_res papyrus_binary_operator_create
	(uint32_t opCode, b_lean_obj_res s1, b_lean_obj_res s2,  b_lean_obj_res nameObj, lean_obj_arg /* w */) {
	auto inst = BinaryOperator::Create(static_cast<Instruction::BinaryOps>(opCode + 1), toValue(s1), toValue(s2), refOfString(nameObj));
	return lean_io_result_mk_ok(mkValueRef(copyLink(s1), inst));
}



} // end namespace papyrus
