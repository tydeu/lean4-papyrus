#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Module.h>

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

// Get the LLVM Module wrapped in an object.
llvm::Module* toModule(lean::object* modObj) {
    auto external = lean_to_external(modObj);
    assert(external->m_class == getModuleClass());
    auto p = static_cast<ContainedExternal<llvm::Module>*>(external->m_data);
    return p->value.get();
}

//------------------------------------------------------------------------------
// Basic functions
//------------------------------------------------------------------------------

// Create a new Lean LLVM Module object with the given ID.
extern "C" obj_res papyrus_module_new(b_obj_arg modIdObj, obj_arg ctxObj, obj_arg /* w */) {
    auto ctx = toLLVMContext(ctxObj);
    auto mod = new llvm::Module(string_to_ref(modIdObj), *ctx);
    return io_result_mk_ok(mk_module_ref(ctxObj, std::unique_ptr<llvm::Module>(mod)));
}

// Get the ID of the module.
extern "C" obj_res papyrus_module_get_id(b_obj_arg modObj, obj_arg /* w */) {
    return io_result_mk_ok(mk_string(toModule(modObj)->getModuleIdentifier()));
}

// Set the ID of the module.
extern "C" obj_res papyrus_module_set_id(b_obj_arg modObj, b_obj_arg modIdObj, obj_arg /* w */) {
    toModule(modObj)->setModuleIdentifier(string_to_ref(modIdObj));
    return io_result_mk_ok(box(0));
}

} // end namespace papyrus
