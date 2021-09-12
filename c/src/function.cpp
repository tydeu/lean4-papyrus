#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Verifier.h>

using namespace llvm;

namespace papyrus {

// Get the LLVM Function pointer wrapped in an object.
llvm::Function* toFunction(lean_object* funRef) {
	return llvm::cast<Function>(toValue(funRef));
}

// Get a reference to a newly created function.
extern "C" lean_obj_res papyrus_function_create
	(b_lean_obj_res typeRef, b_lean_obj_res nameObj, uint8_t linkage,
		uint32_t addrSpace, lean_obj_arg /* w */)
{
	auto* fun = Function::Create(toFunctionType(typeRef),
	static_cast<GlobalValue::LinkageTypes>(linkage), addrSpace, refOfString(nameObj));
	return lean_io_result_mk_ok(mkValueRef(copyLink(typeRef), fun));
}

// Get the nth argument of the function
extern "C" lean_obj_res papyrus_function_get_arg
	(uint32_t argNo, b_lean_obj_res funRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(mkValueRef(copyLink(funRef),
		toFunction(funRef)->getArg(argNo)));
}

// Get an array of references to the basic blocks of the given function.
extern "C" lean_obj_res papyrus_function_get_basic_blocks
	(b_lean_obj_res funRef, lean_obj_arg /* w */)
{
	auto link = borrowLink(funRef);
	auto& bbs = toFunction(funRef)->getBasicBlockList();
	lean_object* arr = lean_alloc_array(0, PAPYRUS_DEFAULT_ARRAY_CAPCITY);
	for (BasicBlock& bb : bbs) {
		lean_inc_ref(link);
		arr = lean_array_push(arr, mkValueRef(link, &bb));
	}
	return lean_io_result_mk_ok(arr);
}

// Add the given instruction to the end of the given basic block.
extern "C" lean_obj_res papyrus_function_append_basic_block
	(b_lean_obj_res bbRef, b_lean_obj_res funRef, lean_obj_arg /* w */)
{
	toFunction(funRef)->getBasicBlockList().push_back(toBasicBlock(bbRef));
	return lean_io_result_mk_ok(lean_box(0));
}

// Check the given function for errors.
// Errors are reported inside the `IO` monad.
extern "C" lean_obj_res papyrus_function_verify
	(b_lean_obj_res funRef, lean_obj_arg /* w */)
{
	std::string ostr;
	raw_string_ostream out(ostr);
	if (llvm::verifyFunction(*toFunction(funRef), &out)) {
		return mkStdStringError(out.str());
	} else {
		return lean_io_result_mk_ok(lean_box(0));
	}
}

// Get whether the function has a specified garbage collection algorithm.
extern "C" lean_obj_res papyrus_function_has_gc
	(b_lean_obj_res funRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toFunction(funRef)->hasGC()));
}

// Get the garbage collection algorithm of a function.
// Should only be called if it is known to have one specified.
extern "C" lean_obj_res papyrus_function_get_gc
	(b_lean_obj_res funRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(mkStringFromStd(toFunction(funRef)->getGC()));
}

// Set the garbage collection algorithm of a function.
extern "C" lean_obj_res papyrus_function_set_gc
	(b_lean_obj_res gcStr, b_lean_obj_res funRef, lean_obj_arg /* w */)
{
	toFunction(funRef)->setGC(stdOfString(gcStr));
	return lean_io_result_mk_ok(lean_box(0));
}

// Remove any specified garbage collection algorithm from the function.
extern "C" lean_obj_res papyrus_function_clear_gc
	(b_lean_obj_res funRef, lean_obj_arg /* w */)
{
	toFunction(funRef)->clearGC();
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the calling convention of a function.
extern "C" lean_obj_res papyrus_function_get_calling_convention
	(b_lean_obj_res funRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toFunction(funRef)->getCallingConv()));
}

// Set the calling convetion of a function.
extern "C" lean_obj_res papyrus_function_set_calling_convention
	(uint32_t callingConv, b_lean_obj_res funRef, lean_obj_arg /* w */)
{
	toFunction(funRef)->setCallingConv(callingConv);
	return lean_io_result_mk_ok(lean_box(0));
}

} // end namespace papyrus
