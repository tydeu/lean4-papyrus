#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/DerivedTypes.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// The Lean object class for LLVM types.
static external_object_class* getTypeClass() {
    // Use static to make this thread safe due to static initialization rule.
    static external_object_class* c = registerOwnedClass<llvm::Type>();
    return c;
}

// Wrap an LLVM Type pointer in a Lean object.
lean::object* mk_type_ref(lean::object* ctx, llvm::Type* ptr) {
    return lean_alloc_external(getTypeClass(), new OwnedExternal<llvm::Type>(ctx, ptr));
}

// Get the LLVM Type pointer wrapped in an object.
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
// Basic types
//------------------------------------------------------------------------------

// Get a reference to the Void type for the given LLVM context.
extern "C" obj_res papyrus_get_void_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getVoidTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the Label type for the given LLVM context.
extern "C" obj_res papyrus_get_label_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getLabelTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the Metadata type for the given LLVM context.
extern "C" obj_res papyrus_get_metadata_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getMetadataTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the Token type for the given LLVM context.
extern "C" obj_res papyrus_get_token_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getTokenTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the X86_MMX type for the given LLVM context.
extern "C" obj_res papyrus_get_x86_mmx_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getX86_MMXTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

//------------------------------------------------------------------------------
// Floating point types
//------------------------------------------------------------------------------

// Get a reference to the Half type type for the given LLVM context.
extern "C" obj_res papyrus_get_half_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getHalfTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the BFloat type type for the given LLVM context.
extern "C" obj_res papyrus_get_bfloat_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getBFloatTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the Float type type for the given LLVM context.
extern "C" obj_res papyrus_get_float_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getFloatTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the Double type type for the given LLVM context.
extern "C" obj_res papyrus_get_double_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getDoubleTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the X86_FP80 type type for the given LLVM context.
extern "C" obj_res papyrus_get_x86_fp80_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getX86_FP80Ty(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the FP128 type type for the given LLVM context.
extern "C" obj_res papyrus_get_fp128_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getFP128Ty(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the PPC_FP128 type type for the given LLVM context.
extern "C" obj_res papyrus_get_ppc_fp128_type(b_obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getPPC_FP128Ty(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

//------------------------------------------------------------------------------
// Derived types
//------------------------------------------------------------------------------

// Get a reference to the integer type of the given bit width
// for the given LLVM context.
extern "C" obj_res papyrus_get_integer_type(
    b_obj_arg numBits, b_obj_arg ctxObj, obj_arg /* w */)
{
    auto type = IntegerType::get(*toLLVMContext(ctxObj), unbox_uint32(numBits));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the pointer type  to the given pointee type
// in the given address space for the given LLVM context.
extern "C" obj_res papyrus_get_pointer_type(
    b_obj_arg pointee, b_obj_arg addrSpace, b_obj_arg ctxObj, obj_arg /* w */)
{
    auto type = PointerType::get(toType(pointee), unbox_uint32(addrSpace));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the array vector type with the given element type
// and the given number of elements for the given LLVM context.
extern "C" obj_res papyrus_get_array_type(
    b_obj_arg elemType, b_obj_arg numElems, b_obj_arg ctxObj, obj_arg /* w */)
{
    auto type = ArrayType::get(toType(elemType), unbox_uint64(numElems));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the fixed vector type with the given element type
// and the given number of elements for the given LLVM context.
extern "C" obj_res papyrus_get_fixed_vector_type(
    b_obj_arg elemType, b_obj_arg numElems, b_obj_arg ctxObj, obj_arg /* w */)
{
    auto type = FixedVectorType::get(toType(elemType), unbox_uint32(numElems));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the scalable vector type with the given element type
// and the given minimum number of elements for the given LLVM context.
extern "C" obj_res papyrus_get_scalable_vector_type(
    b_obj_arg elemType, b_obj_arg minNumElems, b_obj_arg ctxObj, obj_arg /* w */)
{
    auto type = ScalableVectorType::get(toType(elemType), unbox_uint32(minNumElems));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}


} // end namespace papyrus
