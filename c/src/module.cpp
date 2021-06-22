#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Module.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

static external_object_class* getModuleClass() {
    // Use static to make this thread safe due to static initialization rule.
    static external_object_class* c = registerContainedClass<llvm::Module>();
    return c;
}

obj_res allocModule(object* ctx, std::unique_ptr<llvm::Module> mod) {
    return lean_alloc_external(getModuleClass(), new ContainedExternal<llvm::Module>(ctx, std::move(mod)));
}

llvm::Module* toModule(b_obj_arg o) {
    lean_assert(lean_get_external_class(o) == getModuleClass());
    auto p = static_cast<ContainedExternal<llvm::Module>*>(lean_get_external_data(o));
    return p->value.get();
}

extern "C" obj_res papyrus_module_new(b_obj_arg nameObj, b_obj_arg ctxObj, obj_arg /* w */) {
    auto ctx = toLLVMContext(ctxObj);
    auto mod = new llvm::Module(string_to_ref(nameObj), *ctx);
    return io_result_mk_ok(allocModule(ctxObj, std::unique_ptr<llvm::Module>(mod)));
}

extern "C" obj_res papyrus_module_getModuleIdentifier(b_obj_arg modObj, obj_arg /* w */) {
    return io_result_mk_ok(mk_string(toModule(modObj)->getModuleIdentifier()));
}

extern "C" obj_res papyrus_module_setModuleIdentifier(b_obj_arg modObj, b_obj_arg nameObj, obj_arg /* w */) {
    toModule(modObj)->setModuleIdentifier(string_to_ref(nameObj));
    return io_result_mk_ok(box(0));
}

} // end namespace papyrus
