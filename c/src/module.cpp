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
	return mkLinkedLoosePtr<Module>(ctx, modPtr);
}

// Get the LLVM Module wrapped in an object.
llvm::Module* toModule(lean::object* modRef) {
	return fromLinkedLoosePtr<Module>(modRef);
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

// Get the global variable of the given name in the module (or error if it does not exist).
extern "C" obj_res papyrus_module_get_global_variable
	(b_obj_arg nameObj, b_obj_arg modRef, uint8 allowInternal, obj_arg /* w */)
{
	auto gbl = toModule(modRef)->getGlobalVariable(refOfString(nameObj), allowInternal);
	if (gbl) {
		return io_result_mk_ok(mkValueRef(copyLink(modRef), gbl));
	} else {
		return io_result_mk_error(mk_string("Named global variable does not exist in module."));
	}
}

// Get the global variable of the given name in the module (or none if it does not exist).
extern "C" obj_res papyrus_module_get_global_variable_opt
	(b_obj_arg nameObj, b_obj_arg modRef, uint8 allowInternal, obj_arg /* w */)
{
	auto gbl = toModule(modRef)->getGlobalVariable(refOfString(nameObj), allowInternal);
	auto obj = gbl ? mk_option_some(mkValueRef(copyLink(modRef), gbl)) : mk_option_none();
	return io_result_mk_ok(obj);
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

// Get the function of the given name in the module (or error if it does not exist).
extern "C" obj_res papyrus_module_get_function
	(b_obj_arg nameObj, b_obj_arg modRef, obj_arg /* w */)
{
	auto fn = toModule(modRef)->getFunction(refOfString(nameObj));
	if (fn) {
		return io_result_mk_ok(mkValueRef(copyLink(modRef), fn));
	} else {
		return io_result_mk_error(mk_string("Named function does not exist in module."));
	}
}

// Get the function of the given name in the module (or none if it does not exist).
extern "C" obj_res papyrus_module_get_function_opt
	(b_obj_arg nameObj, b_obj_arg modRef, obj_arg /* w */)
{
	auto fn = toModule(modRef)->getFunction(refOfString(nameObj));
	auto obj = fn ? mk_option_some(mkValueRef(copyLink(modRef), fn)) : mk_option_none();
	return io_result_mk_ok(obj);
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

// Check the given module for errors.
// Errors are reported inside the `IO` monad.
// If `warnBrokenDebugInfo` is true, DebugInfo verification failures won't be
// considered as an error and instead the function will return true.
// Otherwise, the function will always return false.
extern "C" obj_res papyrus_module_verify
	(b_obj_arg modRef, uint8 warnBrokenDebugInfo,  obj_arg /* w */)
{
	std::string ostr;
	raw_string_ostream out(ostr);
	if (warnBrokenDebugInfo) {
		bool brokenDebugInfo;
		if (llvm::verifyModule(*toModule(modRef), &out, &brokenDebugInfo)) {
			return io_result_mk_error(out.str());
		} else {
			return io_result_mk_ok(box(brokenDebugInfo));
		}
	} else {
		if (llvm::verifyModule(*toModule(modRef), &out)) {
			return io_result_mk_error(out.str());
		} else {
			return io_result_mk_ok(box(false));
		}
	}
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
