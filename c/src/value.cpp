#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Value.h>
#include <llvm/ADT/Twine.h>
#include <llvm/Support/raw_ostream.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// Value references
//------------------------------------------------------------------------------

// The Lean object class for LLVM values.
static external_object_class* getValueClass() {
    // Use static to make this thread safe due to static initialization rule.
    static external_object_class* c = registerOwnedClass<llvm::Value>();
    return c;
}

// Wrap an LLVM Value pointer in a Lean object.
lean::object* mk_value_ref(lean::object* ctx, llvm::Value* ptr) {
    return lean_alloc_external(getValueClass(), new OwnedExternal<llvm::Value>(ctx, ptr));
}

// Get the LLVM Value external wrapped in an object.
OwnedExternal<llvm::Value>* toValueExternal(lean::object* valueRef) {
    auto external = lean_to_external(valueRef);
    lean_assert(external->m_class == getValueClass());
    return static_cast<OwnedExternal<llvm::Value>*>(external->m_data);
}

// Get the LLVM Value pointer wrapped in an object.
llvm::Value* toValue(lean::object* valueRef) {
    return toValueExternal(valueRef)->value;
}

// Get the owning LLVM context object of the given value.
lean::object* getValueContext(lean::object* valueRef) {
    auto ctx = toValueExternal(valueRef)->owner;
    lean_inc_ref(ctx);
    return ctx;
}

//------------------------------------------------------------------------------
// Basic functions
//------------------------------------------------------------------------------

// Get a reference to the type of the given value.
extern "C" obj_res papyrus_value_get_type(b_obj_arg valueRef, obj_arg /* w */) {
    return io_result_mk_ok(mk_type_ref(getValueContext(valueRef), toValue(valueRef)->getType()));
}

// Get whether the the given value has a name.
extern "C" obj_res papyrus_value_has_name(b_obj_arg valueRef, obj_arg /* w */) {
  return io_result_mk_ok(lean_box(toValue(valueRef)->hasName()));
}

// Get the name of the given value (or the empty string if none).
extern "C" obj_res papyrus_value_get_name(b_obj_arg valueRef, obj_arg /* w */) {
    return io_result_mk_ok(mk_string(toValue(valueRef)->getName()));
}

// Set the name of the given value.
// An empty string will remove the value's name.
extern "C" obj_res papyrus_value_set_name
(b_obj_arg strObj, b_obj_arg valueRef, obj_arg /* w */)
{
    toValue(valueRef)->setName(string_to_twine(strObj));
    return io_result_mk_ok(box(0));
}

// Dump the given value for debugging (to standard error).
extern "C" obj_res papyrus_value_dump(b_obj_arg valueRef, obj_arg /* w */) {
    // simulates Value.dump() since it is not available in release builds.
    toValue(valueRef)->print(llvm::errs(), true); llvm::errs() << "\n";
    return io_result_mk_ok(box(0));
}

} // end namespace papyrus
