#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Verifier.h>
#include <llvm/Support/raw_ostream.h>

using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// Module references
//------------------------------------------------------------------------------

// Wrap an LLVM Module in a Lean object.
lean_object* mkModuleRef(lean_obj_arg ctx, llvm::Module* modPtr) {
	return mkLinkedLoosePtr<Module>(ctx, modPtr);
}

// Get the LLVM Module wrapped in an object.
llvm::Module* toModule(lean_object* modRef) {
	return fromLinkedLoosePtr<Module>(modRef);
}

//------------------------------------------------------------------------------
// Basic functions
//------------------------------------------------------------------------------

// Create a new Lean LLVM Module object with the given ID.
extern "C" lean_obj_res papyrus_module_new
	(lean_obj_arg modIdObj, lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto ctx = toLLVMContext(ctxRef);
	auto mod = new llvm::Module(refOfString(modIdObj), *ctx);
	return lean_io_result_mk_ok(mkModuleRef(ctxRef, mod));
}

// Get the ID of the module.
extern "C" lean_obj_res papyrus_module_get_id
	(b_lean_obj_res modRef, lean_obj_arg /* w */)
{
	auto id = toModule(modRef)->getModuleIdentifier();
	return lean_io_result_mk_ok(mkStringFromStd(id));
}

// Set the ID of the module.
extern "C" lean_obj_res papyrus_module_set_id
	(b_lean_obj_res modRef, b_lean_obj_res modIdObj, lean_obj_arg /* w */)
{
	toModule(modRef)->setModuleIdentifier(refOfString(modIdObj));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the global variable of the given name in the module
// (or error if it does not exist).
extern "C" lean_obj_res papyrus_module_get_global_variable
	(b_lean_obj_res nameObj, b_lean_obj_res modRef, uint8_t allowInternal,
		lean_obj_arg /* w */)
{
	auto gbl = toModule(modRef)->getGlobalVariable(refOfString(nameObj), allowInternal);
	if (gbl) {
		return lean_io_result_mk_ok(mkValueRef(copyLink(modRef), gbl));
	} else {
		return mkStdStringError("Named global variable does not exist in module.");
	}
}

// Get the global variable of the given name in the module
// (or none if it does not exist).
extern "C" lean_obj_res papyrus_module_get_global_variable_opt
	(b_lean_obj_res nameObj, b_lean_obj_res modRef, uint8_t allowInternal,
		lean_obj_arg /* w */)
{
	auto gbl = toModule(modRef)->getGlobalVariable(refOfString(nameObj), allowInternal);
	auto obj = gbl ? mkSome(mkValueRef(copyLink(modRef), gbl)) : lean_box(0);
	return lean_io_result_mk_ok(obj);
}

// Get an array of references to the global variables of the given module.
extern "C" lean_obj_res papyrus_module_get_global_variables
	(b_lean_obj_res modRef, lean_obj_arg /* w */)
{
	auto ctxRef = borrowLink(modRef);
	auto& vars = toModule(modRef)->getGlobalList();
	lean_object* arr = lean_alloc_array(0, PAPYRUS_DEFAULT_ARRAY_CAPCITY);
	for (GlobalVariable& var : vars) {
		lean_inc_ref(ctxRef);
		arr = lean_array_push(arr, mkValueRef(ctxRef, &var));
	}
	return lean_io_result_mk_ok(arr);
}

// Add the given global variable to the end of the module.
extern "C" lean_obj_res papyrus_module_append_global_variable
(b_lean_obj_res funRef, b_lean_obj_res modRef, lean_obj_arg /* w */)
{
	toModule(modRef)->getGlobalList().push_back(toGlobalVariable(funRef));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the function of the given name in the module
// (or error if it does not exist).
extern "C" lean_obj_res papyrus_module_get_function
	(b_lean_obj_res nameObj, b_lean_obj_res modRef, lean_obj_arg /* w */)
{
	auto fn = toModule(modRef)->getFunction(refOfString(nameObj));
	if (fn) {
		return lean_io_result_mk_ok(mkValueRef(copyLink(modRef), fn));
	} else {
		return mkStdStringError("Named function does not exist in module.");
	}
}

// Get the function of the given name in the module (or none if it does not exist).
extern "C" lean_obj_res papyrus_module_get_function_opt
	(b_lean_obj_res nameObj, b_lean_obj_res modRef, lean_obj_arg /* w */)
{
	auto fn = toModule(modRef)->getFunction(refOfString(nameObj));
	auto obj = fn ? mkSome(mkValueRef(copyLink(modRef), fn)) : lean_box(0);
	return lean_io_result_mk_ok(obj);
}

// Get an array of references to the functions of the given module.
extern "C" lean_obj_res papyrus_module_get_functions
	(b_lean_obj_res modRef, lean_obj_arg /* w */)
{
	auto ctxRef = borrowLink(modRef);
	auto& funs = toModule(modRef)->getFunctionList();
	lean_object* arr = lean_alloc_array(0, PAPYRUS_DEFAULT_ARRAY_CAPCITY);
	for (Function& fun : funs) {
		lean_inc_ref(ctxRef);
		arr = lean_array_push(arr, mkValueRef(ctxRef, &fun));
	}
	return lean_io_result_mk_ok(arr);
}

// Add the given function to the end of the module.
extern "C" lean_obj_res papyrus_module_append_function
	(b_lean_obj_res funRef, b_lean_obj_res modRef, lean_obj_arg /* w */)
{
	toModule(modRef)->getFunctionList().push_back(toFunction(funRef));
	return lean_io_result_mk_ok(lean_box(0));
}

// Check the given module for errors.
// Errors are reported inside the `IO` monad.
// If `warnBrokenDebugInfo` is true, DebugInfo verification failures won't be
// considered as an error and instead the function will return true.
// Otherwise, the function will always return false.
extern "C" lean_obj_res papyrus_module_verify
	(b_lean_obj_res modRef, uint8_t warnBrokenDebugInfo,  lean_obj_arg /* w */)
{
	std::string ostr;
	raw_string_ostream out(ostr);
	if (warnBrokenDebugInfo) {
		bool brokenDebugInfo;
		if (llvm::verifyModule(*toModule(modRef), &out, &brokenDebugInfo)) {
			return mkStdStringError(out.str());
		} else {
			return lean_io_result_mk_ok(lean_box(brokenDebugInfo));
		}
	} else {
		if (llvm::verifyModule(*toModule(modRef), &out)) {
			return mkStdStringError(out.str());
		} else {
			return lean_io_result_mk_ok(lean_box(false));
		}
	}
}

// Print the given module to LLVM's standard output.
extern "C" lean_obj_res papyrus_module_print
	(b_lean_obj_res modRef, uint8_t shouldPreserveUseListOrder, uint8_t isForDebug,
		lean_obj_arg /* w */)
{
	toModule(modRef)->print(llvm::outs(), nullptr, shouldPreserveUseListOrder, isForDebug);
	return lean_io_result_mk_ok(lean_box(0));
}

// Print the given module to LLVM's standard error.
extern "C" lean_obj_res papyrus_module_eprint
	(b_lean_obj_res modRef, uint8_t shouldPreserveUseListOrder, uint8_t isForDebug,
		lean_obj_arg /* w */)
{
	toModule(modRef)->print(llvm::errs(), nullptr, shouldPreserveUseListOrder, isForDebug);
	return lean_io_result_mk_ok(lean_box(0));
}

// Print the given module to a string.
extern "C" lean_obj_res papyrus_module_sprint
	(b_lean_obj_res modRef, uint8_t shouldPreserveUseListOrder, uint8_t isForDebug,
		lean_obj_arg /* w */)
{
	std::string ostr;
	raw_string_ostream out(ostr);
	toModule(modRef)->print(out, nullptr, shouldPreserveUseListOrder, isForDebug);
	return lean_io_result_mk_ok(mkStdStringError(out.str()));
}

} // end namespace papyrus
