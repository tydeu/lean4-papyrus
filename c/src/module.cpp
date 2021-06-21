#include "lean_llvm.h"

#include <lean/io.h>
#include <llvm/IR/Module.h>

using namespace lean;
using namespace llvm;

namespace lean_llvm {

// This owns a LLVM module and also a pointer to the context to ensure
// the context is not freed as long as the module is alive.
struct ModuleRec {
    // Lean object for context
    // (we hold a handle to this so that it is not
    // deleted before we are done with the module).
    object* ctxObj;

    std::unique_ptr<llvm::Module> module;

    ModuleRec(const ModuleRec&) = delete;

    ModuleRec(object* c, std::unique_ptr<llvm::Module> m)
	    : ctxObj(c), module(std::move(m)) {}

    ~ModuleRec() {
        module = 0;
        dec_ref(ctxObj);
    }
};

void moduleRecForeach(void * p, b_obj_arg a) {
    ModuleRec* d = static_cast<ModuleRec*>(p);
    apply_1(a, d->ctxObj);
}

static external_object_class* getModuleRecClass() {
    // Use static thread to make this thread safe due to static initialization rule.
    static external_object_class* c(lean_register_external_class(
        &deletePointer<ModuleRec>, &moduleRecForeach));
    return c;
}

obj_res allocModule(object* ctx, std::unique_ptr<llvm::Module> mod) {
    return lean_alloc_external(getModuleRecClass(), new ModuleRec(ctx, std::move(mod)));
}

llvm::Module* toModule(b_obj_arg o) {
    lean_assert(lean_get_external_class(o) == getModuleRecClass());
    auto p = static_cast<ModuleRec*>(lean_get_external_data(o));
    return p->module.get();
}

extern "C" obj_res lean_llvm_module_new(b_obj_arg nameObj, b_obj_arg ctxObj, obj_arg /* w */) {
    auto ctx = toLLVMContext(ctxObj);
    auto mod = new llvm::Module(string_to_ref(nameObj), *ctx);
    return io_result_mk_ok(allocModule(ctxObj, std::unique_ptr<llvm::Module>(mod)));
}

extern "C" obj_res lean_llvm_module_getModuleIdentifier(b_obj_arg m, obj_arg /* w */) {
    return io_result_mk_ok(mk_string(toModule(m)->getModuleIdentifier()));
}

extern "C" obj_res lean_llvm_module_setModuleIdentifier(b_obj_arg modObj, b_obj_arg nameObj, obj_arg /* w */) {
    toModule(modObj)->setModuleIdentifier(string_to_ref(nameObj));
    return io_result_mk_ok(box(0));
}

} // end namespace lean_llvm
