#pragma once
#include <lean/object.h>

// Forward declarations
namespace llvm {
  class StringRef;
  class MemoryBuffer;
  class LLVMContext;
  class Module;
}

namespace papyrus {

//------------------------------------------------------------------------------
// LLVM interfaces
//------------------------------------------------------------------------------

llvm::LLVMContext* toLLVMContext(lean::b_obj_arg o);
llvm::MemoryBuffer* toMemoryBuffer(lean::b_obj_arg o);

llvm::Module* toModule(lean::b_obj_arg o);
lean::obj_res allocModule(lean::object* ctx, std::unique_ptr<llvm::Module> m);

lean::object* mk_string(const llvm::StringRef& s);
const llvm::StringRef string_to_ref(lean::object* o);

//------------------------------------------------------------------------------
// Generic utility functions
//------------------------------------------------------------------------------

// A no-op foreach callback for external classes
void nopForeach(void* p, lean::b_obj_arg a);

// Casts to pointer to the template type and invokes delete
template<typename T>
void deletePointer(void* p) {
    delete static_cast<T*>(p);
}

// Register a class whose external data is a pointer to type `T`
// and whose finalizer just calls delete on the pointer with that type.
template<typename T>
lean::external_object_class* registerDeleteClass() {
    return lean_register_external_class(&deletePointer<T>, &nopForeach);
}

} // end namespace papyrus
