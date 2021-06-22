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


// An external object that is also contained within some other object.
// It holds a handle to this so that it is not deleted before we are
// done with this object.
template<typename T>
struct ContainedExternal {
    // Lean object for the container
    lean::object* container;
    std::unique_ptr<T> value;

    ContainedExternal(const ContainedExternal&) = delete;

    ContainedExternal(lean::object* container, std::unique_ptr<T> value)
	    : container(container), value(std::move(value)) {}

    ~ContainedExternal() {
        value = nullptr;
        lean::dec_ref(container);
    }
};

template<typename T>
void containedExternalForeach(void * p, lean::b_obj_arg a) {
    auto d = static_cast<ContainedExternal<T>*>(p);
   lean::apply_1(a, d->container);
}

// Register a class whose lifetime is extends another objects.
// It holds a reference to the container while alive and releases it when finalized.
template<typename T>
lean::external_object_class* registerContainedClass() {
    return lean_register_external_class(&deletePointer<ContainedExternal<T>>, &containedExternalForeach<T>);
}

} // end namespace papyrus
