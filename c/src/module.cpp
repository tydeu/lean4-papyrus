#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/io.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Verifier.h>
#include <llvm/Support/raw_ostream.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// Module references
//------------------------------------------------------------------------------

// Wrap an LLVM Module in a Lean object.
lean::object* mkModuleRef(obj_arg ctx, llvm::Module* modPtr) {
	return mkLinkedOwnedPtr<Module>(ctx, modPtr);
}

// Get the LLVM Module wrapped in an object.
llvm::Module* toModule(lean::object* modRef) {
	return fromLinkedOwnedPtr<Module>(modRef);
}

//------------------------------------------------------------------------------
// Basic functions
//------------------------------------------------------------------------------

// Create a new Lean LLVM Module object with the given ID.
extern "C" obj_res papyrus_module_new(obj_arg modIdObj, obj_arg ctxRef, obj_arg /* w */) {
	auto ctx = toLLVMContext(ctxRef);
	auto mod = new llvm::Module(refOfString(modIdObj), *ctx);
	return io_result_mk_ok(mkModuleRef(ctxRef, mod));
}

// Get the ID of the module.
extern "C" obj_res papyrus_module_get_id(b_obj_arg modRef, obj_arg /* w */) {
	return io_result_mk_ok(mk_string(toModule(modRef)->getModuleIdentifier()));
}

// Set the ID of the module.
extern "C" obj_res papyrus_module_set_id(b_obj_arg modRef, b_obj_arg modIdObj, obj_arg /* w */) {
	toModule(modRef)->setModuleIdentifier(refOfString(modIdObj));
	return io_result_mk_ok(box(0));
}

// Get an array of references to the global variables of the given module.
extern "C" obj_res papyrus_module_get_global_variables(b_obj_arg modRef, obj_arg /* w */) {
	auto ctxRef = borrowLink(modRef);
	auto& vars = toModule(modRef)->getGlobalList();
	lean_object* arr = lean::alloc_array(0, 8);
	for (GlobalVariable& var : vars) {
		lean_inc_ref(ctxRef);
		arr = lean_array_push(arr, mkValueRef(ctxRef, &var));
	}
	return io_result_mk_ok(arr);
}

// Add the given global variable to the end of the module.
extern "C" obj_res papyrus_module_append_global_variable
(b_obj_arg funRef, b_obj_arg modRef, obj_arg /* w */)
{
	toModule(modRef)->getGlobalList().push_back(toGlobalVariable(funRef));
	return io_result_mk_ok(box(0));
}

// Get an array of references to the functions of the given module.
extern "C" obj_res papyrus_module_get_functions(b_obj_arg modRef, obj_arg /* w */) {
	auto ctxRef = borrowLink(modRef);
	auto& funs = toModule(modRef)->getFunctionList();
	lean_object* arr = lean::alloc_array(0, 8);
	for (Function& fun : funs) {
		lean_inc_ref(ctxRef);
		arr = lean_array_push(arr, mkValueRef(ctxRef, &fun));
	}
	return io_result_mk_ok(arr);
}

// Add the given function to the end of the module.
extern "C" obj_res papyrus_module_append_function
(b_obj_arg funRef, b_obj_arg modRef, obj_arg /* w */)
{
	toModule(modRef)->getFunctionList().push_back(toFunction(funRef));
	return io_result_mk_ok(box(0));
}

// Check the given module for errors (returns true if any errors are found).
extern "C" obj_res papyrus_module_verify(b_obj_arg modRef, obj_arg /* w */) {
	return io_result_mk_ok(box(llvm::verifyModule(*toModule(modRef))));
}

// Print the given module to LLVM's standard output.
extern "C" obj_res papyrus_module_print(b_obj_arg modRef, uint8 shouldPreserveUseListOrder, uint8 isForDebug, obj_arg /* w */) {
	toModule(modRef)->print(llvm::outs(), nullptr, shouldPreserveUseListOrder, isForDebug);
	return io_result_mk_ok(box(0));
}

// Print the given module to LLVM's standard error.
extern "C" obj_res papyrus_module_eprint(b_obj_arg modRef, uint8 shouldPreserveUseListOrder, uint8 isForDebug, obj_arg /* w */) {
	toModule(modRef)->print(llvm::errs(), nullptr, shouldPreserveUseListOrder, isForDebug);
	return io_result_mk_ok(box(0));
}

// Print the given module to a string.
extern "C" obj_res papyrus_module_sprint(b_obj_arg modRef, uint8 shouldPreserveUseListOrder, uint8 isForDebug, obj_arg /* w */) {
	std::string ostr;
	raw_string_ostream out(ostr);
	toModule(modRef)->print(out, nullptr, shouldPreserveUseListOrder, isForDebug);
	return io_result_mk_ok(mk_string(out.str()));
}

} // end namespace papyrus
