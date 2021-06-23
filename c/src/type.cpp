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

// Get the owning LLVM context object of the given type object.
lean::object* getTypeContext(lean::object* typeObj) {
    lean_assert(lean_get_external_class(typeObj) == getTypeClass());
    auto ctx = static_cast<OwnedExternal<llvm::Type>*>(lean_get_external_data(typeObj))->owner;
    lean_inc_ref(ctx);
    return ctx;
}

// Get the owning LLVM context object of the given type object (in Lean).
extern "C" obj_res papyrus_type_get_context(b_obj_arg typeObj, obj_arg /* w */) {
    return io_result_mk_ok(getTypeContext(typeObj));
}

// Get the TypeID of the given type object.
extern "C" obj_res papyrus_type_get_id(b_obj_arg typeObj, obj_arg /* w */) {
    return io_result_mk_ok(lean_box(toType(typeObj)->getTypeID()));
}

//------------------------------------------------------------------------------
// Basic types
//------------------------------------------------------------------------------

// Get a reference to the Void type for the given LLVM context.
extern "C" obj_res papyrus_get_void_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getVoidTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the Label type for the given LLVM context.
extern "C" obj_res papyrus_get_label_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getLabelTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the Metadata type for the given LLVM context.
extern "C" obj_res papyrus_get_metadata_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getMetadataTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the Token type for the given LLVM context.
extern "C" obj_res papyrus_get_token_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getTokenTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the X86_MMX type for the given LLVM context.
extern "C" obj_res papyrus_get_x86_mmx_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getX86_MMXTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

//------------------------------------------------------------------------------
// Floating point types
//------------------------------------------------------------------------------

// Get a reference to the Half type type for the given LLVM context.
extern "C" obj_res papyrus_get_half_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getHalfTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the BFloat type type for the given LLVM context.
extern "C" obj_res papyrus_get_bfloat_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getBFloatTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the Float type type for the given LLVM context.
extern "C" obj_res papyrus_get_float_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getFloatTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the Double type type for the given LLVM context.
extern "C" obj_res papyrus_get_double_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getDoubleTy(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the X86_FP80 type type for the given LLVM context.
extern "C" obj_res papyrus_get_x86_fp80_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getX86_FP80Ty(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the FP128 type type for the given LLVM context.
extern "C" obj_res papyrus_get_fp128_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getFP128Ty(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the PPC_FP128 type type for the given LLVM context.
extern "C" obj_res papyrus_get_ppc_fp128_type(obj_arg ctxObj, obj_arg /* w */) {
    auto type = llvm::Type::getPPC_FP128Ty(*toLLVMContext(ctxObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

//------------------------------------------------------------------------------
// Derived types
//------------------------------------------------------------------------------

// Get a reference to the integer type of the given bit width
// for the given LLVM context.
extern "C" obj_res papyrus_get_integer_type(
    uint32_t numBits, obj_arg ctxObj, obj_arg /* w */)
{
    auto type = IntegerType::get(*toLLVMContext(ctxObj), numBits);
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the pointer type
// to the given pointee type in the given address space.
extern "C" obj_res papyrus_get_pointer_type(
    b_obj_arg pointeeObj, uint32_t addrSpace, obj_arg /* w */)
{
    auto type = PointerType::get(toType(pointeeObj), addrSpace);
    return io_result_mk_ok(mk_type_ref(getTypeContext(pointeeObj), type));
}

// Get a reference to the array type
// with the given element type and the given number of elements.
extern "C" obj_res papyrus_get_array_type(
    b_obj_arg elemTypeObj, uint64_t numElems, obj_arg /* w */)
{
    auto type = ArrayType::get(toType(elemTypeObj), numElems);
    return io_result_mk_ok(mk_type_ref(getTypeContext(elemTypeObj), type));
}

// Get a reference to the vector type
// with the given element type, element quantity, and scalability.
extern "C" obj_res papyrus_get_vector_type(
    b_obj_arg elemTypeObj, uint32_t numElems, uint8_t scalable, obj_arg /* w */)
{
    auto type = VectorType::get(toType(elemTypeObj), numElems, scalable);
    return io_result_mk_ok(mk_type_ref(getTypeContext(elemTypeObj), type));
}

} // end namespace papyrus
