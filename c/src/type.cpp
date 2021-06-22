#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/DerivedTypes.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// Lean object class for LLVM types.
static external_object_class* getTypeClass() {
    // Use static to make this thread safe due to static initialization rule.
    static external_object_class* c = registerOwnedClass<llvm::Type>();
    return c;
}

// Wrap an LLVM Type in a Lean object.
lean::object* mk_type(lean::object* ctx, llvm::Type* ptr) {
    return lean_alloc_external(getTypeClass(), new OwnedExternal<llvm::Type>(ctx, ptr));
}

// Get the LLVM Type wrapped in an object.
llvm::Type* toType(lean::object* obj) {
    lean_assert(lean_get_external_class(obj) == getTypeClass());
    return static_cast<OwnedExternal<llvm::Type>*>(lean_get_external_data(obj))->value;
}

// Get the owning LLVM context of the given type object.
extern "C" obj_res papyrus_type_get_context(b_obj_arg typeObj, obj_arg /* w */) {
    lean_assert(lean_get_external_class(typeObj) == getTypeClass());
    auto ctx = static_cast<OwnedExternal<llvm::Type>*>(lean_get_external_data(typeObj))->owner;
    lean_inc_ref(ctx);
    return io_result_mk_ok(ctx);
}

// Get the TypeID of the given type object.
extern "C" obj_res papyrus_type_get_id(b_obj_arg typeObj, obj_arg /* w */) {
    return io_result_mk_ok(lean_box(toType(typeObj)->getTypeID()));
}

// Get the subclass data of the given type object.
extern "C" obj_res papyrus_type_get_data(b_obj_arg typeObj, obj_arg /* w */) {
    // Hack: Exploit the fact that the bit width of an Integer type is the subclass data.
    auto data = reinterpret_cast<IntegerType*>(toType(typeObj))->getBitWidth();
    return io_result_mk_ok(lean_box_uint32(data));
}

//------------------------------------------------------------------------------
// Primitive types
//------------------------------------------------------------------------------

// Get the builtin void type for the given LLVM context.
extern "C" obj_res papyrus_type_get_void(b_obj_arg ctxObj, obj_arg /* w */) {
    return io_result_mk_ok(mk_type(ctxObj, llvm::Type::getVoidTy(*toLLVMContext(ctxObj))));
}

// Get the builtin half type for the given LLVM context.
extern "C" obj_res papyrus_type_get_half(b_obj_arg ctxObj, obj_arg /* w */) {
    return io_result_mk_ok(mk_type(ctxObj, llvm::Type::getHalfTy(*toLLVMContext(ctxObj))));
}

// Get the builtin float type for the given LLVM context.
extern "C" obj_res papyrus_type_get_float(b_obj_arg ctxObj, obj_arg /* w */) {
    return io_result_mk_ok(mk_type(ctxObj, llvm::Type::getFloatTy(*toLLVMContext(ctxObj))));
}

// Get the builtin double type for the given LLVM context.
extern "C" obj_res papyrus_type_get_double(b_obj_arg ctxObj, obj_arg /* w */) {
    return io_result_mk_ok(mk_type(ctxObj, llvm::Type::getDoubleTy(*toLLVMContext(ctxObj))));
}

} // end namespace papyrus
