#include "papyrus.h"
#include "papyrus_ffi.h"

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
extern "C" obj_res papyrus_function_create
(b_obj_arg typeRef, b_obj_arg nameObj, uint8 linkage, uint32 addrSpace, obj_arg /* w */)
{
	auto* fun = Function::Create(toFunctionType(typeRef),
	static_cast<GlobalValue::LinkageTypes>(linkage), addrSpace, refOfString(nameObj));
	return io_result_mk_ok(mkValueRef(copyLink(typeRef), fun));
}

// Get the nth argument of the function
extern "C" obj_res papyrus_function_get_arg(uint32 argNo, b_obj_arg funRef, obj_arg /* w */) {
	return io_result_mk_ok(mkValueRef(copyLink(funRef), toFunction(funRef)->getArg(argNo)));
}

// Get an array of references to the basic blocks of the given function.
extern "C" obj_res papyrus_function_get_basic_blocks(b_obj_arg funRef, obj_arg /* w */) {
	auto link = borrowLink(funRef);
	auto& bbs = toFunction(funRef)->getBasicBlockList();
	lean_object* arr = lean::alloc_array(0, 8);
	for (BasicBlock& bb : bbs) {
		lean_inc_ref(link);
		arr = lean_array_push(arr, mkValueRef(link, &bb));
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

// Get whether the function has a specified garbage collection algorithm.
extern "C" obj_res papyrus_function_has_gc(b_obj_arg funRef, obj_arg /* w */) {
	return io_result_mk_ok(box(toFunction(funRef)->hasGC()));
}

// Get the garbage collection algorithm of a function.
// Should only be called if it is known to have one specified.
extern "C" obj_res papyrus_function_get_gc(b_obj_arg funRef, obj_arg /* w */) {
	return io_result_mk_ok(mk_string(toFunction(funRef)->getGC()));
}

// Set the garbage collection algorithm of a function.
extern "C" obj_res papyrus_function_set_gc
	(b_obj_arg gcStr, b_obj_arg funRef, obj_arg /* w */)
{
	toFunction(funRef)->setGC(string_to_std(gcStr));
	return io_result_mk_ok(box(0));
}

// Remove any specified garbage collection algorithm from the function.
extern "C" obj_res papyrus_function_clear_gc(b_obj_arg funRef, obj_arg /* w */) {
	toFunction(funRef)->clearGC();
	return io_result_mk_ok(box(0));
}

// Get the calling convention of a function.
extern "C" obj_res papyrus_function_get_calling_convention
	(b_obj_arg funRef, obj_arg /* w */)
{
	return io_result_mk_ok(box(toFunction(funRef)->getCallingConv()));
}

// Set the calling convetion of a function.
extern "C" obj_res papyrus_function_set_calling_convention
	(uint32 callingConv, b_obj_arg funRef, obj_arg /* w */)
{
	toFunction(funRef)->setCallingConv(callingConv);
	return io_result_mk_ok(box(0));
}

} // end namespace papyrus
