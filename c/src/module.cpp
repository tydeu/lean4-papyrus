#include "papyrus.h"

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

// Lean object class for LLVM modules.
static external_object_class* getModuleClass() {
    // Use static to make this thread safe due to static initialization rule.
    static external_object_class* c = registerContainedClass<llvm::Module>();
    return c;
}

// Wrap an LLVM Module in a Lean object.
lean::object* mk_module_ref(lean::object* ctx, std::unique_ptr<llvm::Module> mod) {
    return lean_alloc_external(getModuleClass(), new ContainedExternal<llvm::Module>(ctx, std::move(mod)));
}

// Get the LLVM Module external in an object.
ContainedExternal<llvm::Module>* toModuleExternal(lean::object* modRef) {
    auto external = lean_to_external(modRef);
    assert(external->m_class == getModuleClass());
    return static_cast<ContainedExternal<llvm::Module>*>(external->m_data);
}

// Get the LLVM Module wrapped in an object.
llvm::Module* toModule(lean::object* modRef) {
    return toModuleExternal(modRef)->value.get();
}

// Get the container LLVM context object of the given module.
lean::object* getBorrowedModuleContext(lean::object* valueRef) {
    return toModuleExternal(valueRef)->container;
}

//------------------------------------------------------------------------------
// Basic functions
//------------------------------------------------------------------------------

// Create a new Lean LLVM Module object with the given ID.
extern "C" obj_res papyrus_module_new(b_obj_arg modIdObj, obj_arg ctxRef, obj_arg /* w */) {
    auto ctx = toLLVMContext(ctxRef);
    auto mod = new llvm::Module(string_to_ref(modIdObj), *ctx);
    return io_result_mk_ok(mk_module_ref(ctxRef, std::unique_ptr<llvm::Module>(mod)));
}

// Get the ID of the module.
extern "C" obj_res papyrus_module_get_id(b_obj_arg modRef, obj_arg /* w */) {
    return io_result_mk_ok(mk_string(toModule(modRef)->getModuleIdentifier()));
}

// Set the ID of the module.
extern "C" obj_res papyrus_module_set_id(b_obj_arg modRef, b_obj_arg modIdObj, obj_arg /* w */) {
    toModule(modRef)->setModuleIdentifier(string_to_ref(modIdObj));
    return io_result_mk_ok(box(0));
}

// Get an array of references to the functions of the given module.
extern "C" obj_res papyrus_module_get_functions(b_obj_arg modRef, obj_arg /* w */) {
    auto ctxRef = getBorrowedModuleContext(modRef);
    auto& funs = toModule(modRef)->getFunctionList();
    lean_object* arr = lean::alloc_array(0, 8);
    for (Function& fun : funs) {
        lean_inc_ref(ctxRef);
        arr = lean_array_push(arr, mk_value_ref(ctxRef, &fun));
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

// Dump the given module for debugging (to standard error).
extern "C" obj_res papyrus_module_dump(b_obj_arg modRef, obj_arg /* w */) {
    // simulates Module.dump() since it is not available in release builds
    toModule(modRef)->print(llvm::errs(), nullptr, false, true);
    return io_result_mk_ok(box(0));
}

} // end namespace papyrus
