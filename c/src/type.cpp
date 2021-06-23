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

//------------------------------------------------------------------------------
// Derived types
//------------------------------------------------------------------------------

// Get the integer type of given bit width for the given LLVM context.
extern "C" obj_res papyrus_type_get_integer(
    b_obj_arg numBits, b_obj_arg ctxObj, obj_arg /* w */)
{
    auto type = IntegerType::get(*toLLVMContext(ctxObj), unbox_uint32(numBits));
    return io_result_mk_ok(mk_type(ctxObj, type));
}

//  Get a pointer type to `pointee` in the given address space for the given LLVM context.
extern "C" obj_res papyrus_type_get_pointer(
    b_obj_arg pointee, b_obj_arg addrSpace, b_obj_arg ctxObj, obj_arg /* w */)
{
    auto type = PointerType::get(toType(pointee), unbox_uint32(addrSpace));
    return io_result_mk_ok(mk_type(ctxObj, type));
}

} // end namespace papyrus
