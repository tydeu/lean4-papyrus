#pragma once
#include <lean/object.h>

// Forward declarations
namespace llvm {
    class APInt;
    class Twine;
    class StringRef;
    class LLVMContext;
    class Module;
    class Type;
    class IntegerType;
    class Value;
    class Instruction;
}

namespace papyrus {

//------------------------------------------------------------------------------
// LLVM interfaces
//------------------------------------------------------------------------------

lean::object* mk_nat(const llvm::APInt& ap);
lean::object* mk_int(const llvm::APInt& ap);
const llvm::APInt nat_to_ap(unsigned numBits, lean::object* obj);
const llvm::APInt int_to_ap(unsigned numBits, lean::object* obj);

lean::object* mk_string(const llvm::StringRef& str);
const llvm::StringRef string_to_ref(lean::object* obj);

lean::object* mk_context_ref(llvm::LLVMContext* ctx);
llvm::LLVMContext* toLLVMContext(lean::object* ctxRef);

lean::object* mk_module_ref(lean::object* ctxRef, std::unique_ptr<llvm::Module> mod);
llvm::Module* toModule(lean::object* modObj);

lean::object* mk_type_ref(lean::object* ctxRef, llvm::Type* type);
lean::object* getTypeContext(lean::object* typeRef);
llvm::Type* toType(lean::object* typeRef);
llvm::IntegerType* toIntegerType(lean::object* typeRef);

lean::object* mk_value_ref(lean::object* ctxRef, llvm::Value* value);
lean::object* getValueContext(lean::object* valueRef);
lean::object* getBorrowedValueContext(lean::object* valueRef);
llvm::Value* toValue(lean::object* valueRef);
llvm::Instruction* toInstruction(lean::object* instRef);

//------------------------------------------------------------------------------
// Generic utilities
//------------------------------------------------------------------------------

// A no-op foreach callback for external classes
static void nopForeach(void* /* p */, lean::b_obj_arg /* a */) {
  return;
}

// Casts the pointer to the template type and invokes delete
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

// An external object that is also weakly contained within some other object.
// It holds a reference to the container so that the container is not
// garbage collected before this object is deleted.
// However, this object *can* be garbaged collected naturally and will remove
// itself from its container upon deletion.
template<typename T>
struct ContainedExternal {
    ContainedExternal(lean::object* container, std::unique_ptr<T> value)
	    : container(container), value(std::move(value)) {}

    ContainedExternal(const ContainedExternal&) = delete;

    ~ContainedExternal() {
        value = nullptr;
        lean_dec_ref(container);
    }

    // Lean object for the container.
    lean::object* container;

    // The handle for the external value.
    // Deleted upon garbage collection of this object.
    std::unique_ptr<T> value;
};

// A foreach for contained externals that applies its argument to the container.
template<typename T>
void containedExternalForeach(void * p, lean::b_obj_arg a) {
    auto d = static_cast<ContainedExternal<T>*>(p);
    lean_apply_1(a, d->container);
}

// Register a class whose lifetime is extends another objects.
// It holds a reference to the container while alive and releases it when finalized.
template<typename T>
lean::external_object_class* registerContainedClass() {
    return lean_register_external_class(&deletePointer<ContainedExternal<T>>, &containedExternalForeach<T>);
}

// An external object that is owned by some other object.
// It holds a reference to its owner so that the owner is not garbage collected
// before this object is deleted.
// The external value will *not* be deleted when the object is garbadge collected.
template<typename T>
struct OwnedExternal {
    OwnedExternal(lean::object* owner, T* value)
        : owner(owner), value(value) {}

    OwnedExternal(const OwnedExternal& other)
        : owner(other.owner), value(other.value)
    {
        lean_inc_ref(owner);
    };

    ~OwnedExternal() {
        lean_dec_ref(owner);
    }

     // Lean object for the owner.
    lean::object* owner;

    // The handle for the external value.
    // The owner is responsible for deleting it.
    T* value;
};

// A foreach for owned externals that applies its argument to the container.
template<typename T>
void ownedExternalForeach(void *p, lean::b_obj_arg a) {
    auto d = static_cast<OwnedExternal<T>*>(p);
    lean_apply_1(a, d->owner);
}

// Register a class whose lifetime is controlled by another object.
// It holds a reference to the owner while alive and releases it when finalized.
template<typename T>
lean::external_object_class* registerOwnedClass() {
    return lean_register_external_class(&deletePointer<OwnedExternal<T>>, &ownedExternalForeach<T>);
}

} // end namespace papyrus
