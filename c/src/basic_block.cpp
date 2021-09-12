#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/IR/BasicBlock.h>

using namespace llvm;

namespace papyrus {

// Get the LLVM BasicBlock pointer wrapped in an object.
llvm::BasicBlock* toBasicBlock(lean_object* bbRef) {
	return llvm::cast<BasicBlock>(toValue(bbRef));
}

// Get a reference to a newly created basic block.
extern "C" lean_obj_res papyrus_basic_block_create
	(b_lean_obj_arg nameObj, lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto bb = BasicBlock::Create(*toLLVMContext(ctxRef), refOfString(nameObj));
	return lean_io_result_mk_ok(mkValueRef(ctxRef, bb));
}

// Get an array of references to the instructions of the given basic block.
extern "C" lean_obj_res papyrus_basic_block_get_instructions
	(b_lean_obj_arg bbRef, lean_obj_arg /* w */)
{
	auto link = borrowLink(bbRef);
	auto& is = toBasicBlock(bbRef)->getInstList();
	lean_object* arr = lean_alloc_array(0, PAPYRUS_DEFAULT_ARRAY_CAPCITY);
	for (llvm::Instruction& i : is) {
		lean_inc_ref(link);
		arr = lean_array_push(arr, mkValueRef(link, &i));
	}
	return lean_io_result_mk_ok(arr);
}

// Add the given instruction to the end of the given basic block.
extern "C" lean_obj_res papyrus_basic_block_append_instruction
	(b_lean_obj_arg instRef, b_lean_obj_arg bbRef, lean_obj_arg /* w */)
{
	toBasicBlock(bbRef)->getInstList().push_back(toInstruction(instRef));
	return lean_io_result_mk_ok(lean_box(0));
}

} // end namespace papyrus
