#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/IR/LLVMContext.h>

using namespace llvm;

namespace papyrus {

// Wrap an LLVMContext in a Lean object.
lean_object* mkContextRef(LLVMContext* ctx) {
	return mkOwnedPtr<LLVMContext>(ctx);
}

// Get the LLVMContext wrapped in an object.
LLVMContext* toLLVMContext(lean_object* ref) {
	return fromOwnedPtr<LLVMContext>(ref);
}

// Create a new Lean LLVM Context object.
extern "C" lean_obj_res papyrus_context_new(lean_obj_arg /* w */) {
	return lean_io_result_mk_ok(mkContextRef(new LLVMContext()));
}

} // end namespace papyrus
