#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/LLVMContext.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// Lean object class for LLVM contexts.
static external_object_class* getLLVMContextClass() {
	// Use static to make this thread safe by static initialization rules.
	static external_object_class* c = registerDeleteClass<LLVMContext>();
	return c;
}

// Wrap an LLVMContext in a Lean object.
lean::object* mk_context_ref(LLVMContext* ctx) {
	return lean_alloc_external(getLLVMContextClass(), ctx);;
}

// Get the LLVMContext wrapped in an object.
LLVMContext* toLLVMContext(lean::object* ctxRef) {
	auto external = lean_to_external(ctxRef);
	assert(external->m_class == getLLVMContextClass());
	return static_cast<LLVMContext*>(external->m_data);
}

// Create a new Lean LLVM Context object.
extern "C" obj_res papyrus_context_new(obj_arg /* w */) {
	auto ctx = new LLVMContext();
	return io_result_mk_ok(mk_context_ref(new LLVMContext()));
}

} // end namespace papyrus
