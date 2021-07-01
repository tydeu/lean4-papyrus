#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/io.h>
#include <llvm/IR/LLVMContext.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// Wrap an LLVMContext in a Lean object.
lean::object* mkContextRef(LLVMContext* ctx) {
	return mkOwnedPtr<LLVMContext>(ctx);
}

// Get the LLVMContext wrapped in an object.
LLVMContext* toLLVMContext(lean::object* ref) {
	return fromOwnedPtr<LLVMContext>(ref);
}

// Create a new Lean LLVM Context object.
extern "C" obj_res papyrus_context_new(obj_arg /* w */) {
	return io_result_mk_ok(mkContextRef(new LLVMContext()));
}

} // end namespace papyrus
