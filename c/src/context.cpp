#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/LLVMContext.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// Class for freshly created LLVM contexts.
static external_object_class* getLLVMContextClass() {
    // Use static to make this thread safe by static initialization rules.
    static external_object_class* c = registerDeleteClass<LLVMContext>();
    return c;
}

// Get the LLVM context associated with the object.
LLVMContext* toLLVMContext(b_obj_arg o) {
    lean_assert(lean_get_external_class(o) == getLLVMContextClass());
    return static_cast<LLVMContext*>(lean_get_external_data(o));
}

// Create a new LLVM context object.
extern "C" obj_res papyrus_context_new(obj_arg /* w */) {
    auto ctx = new LLVMContext();
    object* ctxObj = lean_alloc_external(getLLVMContextClass(), ctx);
    return io_result_mk_ok(ctxObj);
}

} // end namespace papyrus
