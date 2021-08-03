#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/io.h>
#include <llvm/IR/GlobalVariable.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// Get the LLVM GlobalVariable pointer wrapped in an object.
llvm::GlobalVariable* toGlobalVariable(lean::object* ref) {
	return llvm::cast<GlobalVariable>(toValue(ref));
}

// Get a reference to a newly created global variable without an initializer.
extern "C" obj_res papyrus_global_variable_new
(b_obj_arg typeRef, uint8 isConstant, uint8 linkage, b_obj_arg nameObj,
   uint8 tlm, uint32 addrSpace, uint8 externInit, obj_arg /* w */)
{
	auto var = new GlobalVariable(toType(typeRef), isConstant,
	  static_cast<GlobalValue::LinkageTypes>(linkage), nullptr, refOfString(nameObj),
    static_cast<GlobalValue::ThreadLocalMode>(tlm), addrSpace, externInit);
	return io_result_mk_ok(mkValueRef(copyLink(typeRef), var));
}

// Get a reference to a newly created global variable with an initializer.
extern "C" obj_res papyrus_global_variable_new_with_init
(b_obj_arg typeRef, uint8 isConstant, uint8 linkage, b_obj_arg initializerObj,
	b_obj_arg nameObj, uint8 tlm, uint32 addrSpace, uint8 externInit, obj_arg /* w */)
{
	auto var = new GlobalVariable(toType(typeRef), isConstant,
	  static_cast<GlobalValue::LinkageTypes>(linkage), toConstant(initializerObj),
		refOfString(nameObj), static_cast<GlobalValue::ThreadLocalMode>(tlm),
		addrSpace, externInit);
	return io_result_mk_ok(mkValueRef(copyLink(typeRef), var));
}


// Get whether this global variable is constant.
extern "C" obj_res papyrus_global_variable_is_constant
(b_obj_arg varRef, obj_arg /* w */)
{
  auto b = toGlobalVariable(varRef)->isConstant();
	return io_result_mk_ok(box(b));
}

// Set whether this global variable is constant.
extern "C" obj_res papyrus_global_variable_set_constant
(uint8 isConstant, b_obj_arg varRef, obj_arg /* w */)
{
	toGlobalVariable(varRef)->setConstant(isConstant);
	return io_result_mk_ok(box(isConstant));
}

// Get whether this global variable has a (local) initializer.
extern "C" obj_res papyrus_global_variable_has_initializer
  (b_obj_arg varRef, obj_arg /* w */)
{
	return io_result_mk_ok(box(toGlobalVariable(varRef)->hasInitializer()));
}

// Get the (local) initializer of this global variable.
// Only call this if the global variable is know to have one
// (i.e., because hasInitializer return true).
extern "C" obj_res papyrus_global_variable_get_initializer
	(b_obj_arg varRef, obj_arg /* w */)
{
	auto initializer = toGlobalVariable(varRef)->getInitializer();
	return io_result_mk_ok(mkValueRef(getValueContext(varRef), initializer));
}

// Set the initializer of this global variable.
extern "C" obj_res papyrus_global_variable_set_initializer
(b_obj_arg initializerObj, b_obj_arg varRef, obj_arg /* w */)
{
	toGlobalVariable(varRef)->setInitializer(toConstant(initializerObj));
	return io_result_mk_ok(box(0));
}

// Remove the initializer of this global variable.
extern "C" obj_res papyrus_global_variable_remove_initializer
(b_obj_arg initializerObj, b_obj_arg varRef, obj_arg /* w */)
{
	toGlobalVariable(varRef)->setInitializer(nullptr);
	return io_result_mk_ok(box(0));
}

// Get whether this global variable is externally initialized.
extern "C" obj_res papyrus_global_variable_is_externally_initialized
  (b_obj_arg varRef, obj_arg /* w */)
{
	return io_result_mk_ok(box(toGlobalVariable(varRef)->isExternallyInitialized()));
}

// Set whether this global variable is externally initialized.
extern "C" obj_res papyrus_global_variable_set_externally_initialized
(uint8 externallyInitialized, b_obj_arg varRef, obj_arg /* w */)
{
	toGlobalVariable(varRef)->setExternallyInitialized(externallyInitialized);
	return io_result_mk_ok(box(0));
}

} // end namespace papyrus
