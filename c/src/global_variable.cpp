#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/IR/GlobalVariable.h>

using namespace llvm;

namespace papyrus {

// Get the LLVM GlobalVariable pointer wrapped in an object.
llvm::GlobalVariable* toGlobalVariable(lean_object* ref) {
	return llvm::cast<GlobalVariable>(toValue(ref));
}

// Get a reference to a newly created global variable without an initializer.
extern "C" lean_obj_res papyrus_global_variable_new
	(b_lean_obj_res typeRef, uint8_t isConstant, uint8_t linkage, b_lean_obj_res nameObj,
  	uint8_t tlm, uint32_t addrSpace, uint8_t externInit, lean_obj_arg /* w */)
{
	auto var = new GlobalVariable(toType(typeRef), isConstant,
	  static_cast<GlobalValue::LinkageTypes>(linkage), nullptr, refOfString(nameObj),
    static_cast<GlobalValue::ThreadLocalMode>(tlm), addrSpace, externInit);
	return lean_io_result_mk_ok(mkValueRef(copyLink(typeRef), var));
}

// Get a reference to a newly created global variable with an initializer.
extern "C" lean_obj_res papyrus_global_variable_new_with_init
	(b_lean_obj_res typeRef, uint8_t isConstant, uint8_t linkage,
		b_lean_obj_res initializerObj, b_lean_obj_res nameObj, uint8_t tlm,
		uint32_t addrSpace, uint8_t externInit, lean_obj_arg /* w */)
{
	auto var = new GlobalVariable(toType(typeRef), isConstant,
	  static_cast<GlobalValue::LinkageTypes>(linkage), toConstant(initializerObj),
		refOfString(nameObj), static_cast<GlobalValue::ThreadLocalMode>(tlm),
		addrSpace, externInit);
	return lean_io_result_mk_ok(mkValueRef(copyLink(typeRef), var));
}


// Get whether this global variable is constant.
extern "C" lean_obj_res papyrus_global_variable_is_constant
(b_lean_obj_res varRef, lean_obj_arg /* w */)
{
  auto b = toGlobalVariable(varRef)->isConstant();
	return lean_io_result_mk_ok(lean_box(b));
}

// Set whether this global variable is constant.
extern "C" lean_obj_res papyrus_global_variable_set_constant
(uint8_t isConstant, b_lean_obj_res varRef, lean_obj_arg /* w */)
{
	toGlobalVariable(varRef)->setConstant(isConstant);
	return lean_io_result_mk_ok(lean_box(isConstant));
}

// Get whether this global variable has a (local) initializer.
extern "C" lean_obj_res papyrus_global_variable_has_initializer
  (b_lean_obj_res varRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toGlobalVariable(varRef)->hasInitializer()));
}

// Get the (local) initializer of this global variable.
// Only call this if the global variable is know to have one
// (i.e., because hasInitializer return true).
extern "C" lean_obj_res papyrus_global_variable_get_initializer
	(b_lean_obj_res varRef, lean_obj_arg /* w */)
{
	auto initializer = toGlobalVariable(varRef)->getInitializer();
	return lean_io_result_mk_ok(mkValueRef(getValueContext(varRef), initializer));
}

// Set the initializer of this global variable.
extern "C" lean_obj_res papyrus_global_variable_set_initializer
(b_lean_obj_res initializerObj, b_lean_obj_res varRef, lean_obj_arg /* w */)
{
	toGlobalVariable(varRef)->setInitializer(toConstant(initializerObj));
	return lean_io_result_mk_ok(lean_box(0));
}

// Remove the initializer of this global variable.
extern "C" lean_obj_res papyrus_global_variable_remove_initializer
(b_lean_obj_res initializerObj, b_lean_obj_res varRef, lean_obj_arg /* w */)
{
	toGlobalVariable(varRef)->setInitializer(nullptr);
	return lean_io_result_mk_ok(lean_box(0));
}

// Get whether this global variable is externally initialized.
extern "C" lean_obj_res papyrus_global_variable_is_externally_initialized
  (b_lean_obj_res varRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toGlobalVariable(varRef)->isExternallyInitialized()));
}

// Set whether this global variable is externally initialized.
extern "C" lean_obj_res papyrus_global_variable_set_externally_initialized
(uint8_t externallyInitialized, b_lean_obj_res varRef, lean_obj_arg /* w */)
{
	toGlobalVariable(varRef)->setExternallyInitialized(externallyInitialized);
	return lean_io_result_mk_ok(lean_box(0));
}

} // end namespace papyrus
