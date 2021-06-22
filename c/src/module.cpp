#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Module.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// Lean object class for LLVM modules.
static external_object_class* getModuleClass() {
    // Use static to make this thread safe due to static initialization rule.
    static external_object_class* c = registerContainedClass<llvm::Module>();
    return c;
}

// Wrap an LLVM Module in a Lean object.
lean::object* mk_module(lean::object* ctx, std::unique_ptr<llvm::Module> mod) {
    return lean_alloc_external(getModuleClass(), new ContainedExternal<llvm::Module>(ctx, std::move(mod)));
}

// Get the LLVM Module wrapped in an object.
llvm::Module* toModule(b_obj_arg obj) {
    lean_assert(lean_get_external_class(obj) == getModuleClass());
    auto p = static_cast<ContainedExternal<llvm::Module>*>(lean_get_external_data(obj));
    return p->value.get();
}

// Create a new Lean LLVM Module object with the given ID.
extern "C" obj_res papyrus_module_new(b_obj_arg modIdObj, b_obj_arg ctxObj, obj_arg /* w */) {
    auto ctx = toLLVMContext(ctxObj);
    auto mod = new llvm::Module(string_to_ref(modIdObj), *ctx);
    return io_result_mk_ok(mk_module(ctxObj, std::unique_ptr<llvm::Module>(mod)));
}

// Get the ID of the module.
extern "C" obj_res papyrus_module_getModuleIdentifier(b_obj_arg modObj, obj_arg /* w */) {
    return io_result_mk_ok(mk_string(toModule(modObj)->getModuleIdentifier()));
}

// Set the ID of the module.
extern "C" obj_res papyrus_module_setModuleIdentifier(b_obj_arg modObj, b_obj_arg modIdObj, obj_arg /* w */) {
    toModule(modObj)->setModuleIdentifier(string_to_ref(modIdObj));
    return io_result_mk_ok(box(0));
}

} // end namespace papyrus
