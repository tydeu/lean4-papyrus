#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/DerivedTypes.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// Type references
//------------------------------------------------------------------------------

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

// Get the LLVM Type external wrapped in an object.
OwnedExternal<llvm::Type>* toTypeExternal(lean::object* typeObj) {
    auto external = lean_to_external(typeObj);
    assert(external->m_class == getTypeClass());
    return static_cast<OwnedExternal<llvm::Type>*>(external->m_data);
}

// Get the LLVM Type pointer wrapped in an object.
llvm::Type* toType(lean::object* typeObj) {
    return toTypeExternal(typeObj)->value;
}

// Get the owning LLVM context object of the given type object.
lean::object* getTypeContext(lean::object* typeObj) {
    auto ctx = toTypeExternal(typeObj)->owner;
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
// Basic derived types
//------------------------------------------------------------------------------

// Get a reference to the integer type of the given bit width
// for the given LLVM context.
extern "C" obj_res papyrus_get_integer_type(
    uint32_t numBits, obj_arg ctxObj, obj_arg /* w */)
{
    auto type = IntegerType::get(*toLLVMContext(ctxObj), numBits);
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the function type with the given parameters and result.
extern "C" obj_res papyrus_get_function_type(
    b_obj_arg resultObj, b_obj_arg paramsObj, uint8_t isVarArgs, obj_arg /* w */)
{
    lean_array_object* arrObj = lean_to_array(paramsObj);
    size_t len = arrObj->m_size;
    llvm::Type* types[len];
    for (size_t i = 0; i < len; i++) {
        types[i] = toType(arrObj->m_data[i]);
    }
    ArrayRef<llvm::Type*> params(types, len);
    auto type = FunctionType::get(toType(resultObj), params, isVarArgs);
    return io_result_mk_ok(mk_type_ref(getTypeContext(resultObj), type));
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
    b_obj_arg elemTypeObj, uint32_t numElems, uint8_t isScalable, obj_arg /* w */)
{
    auto type = VectorType::get(toType(elemTypeObj), numElems, isScalable);
    return io_result_mk_ok(mk_type_ref(getTypeContext(elemTypeObj), type));
}

//------------------------------------------------------------------------------
// Struct types
//------------------------------------------------------------------------------

// Get a reference to a complete struct type with the given elements and packing.
extern "C" obj_res papyrus_get_struct_type(
    b_obj_arg nameObj, b_obj_arg elemsObj, uint8_t isPacked, obj_arg ctxObj, obj_arg /* w */)
{
    lean_array_object* arrObj = lean_to_array(elemsObj);
    size_t len = arrObj->m_size;
    llvm::Type* types[len];
    for (size_t i = 0; i < len; i++) {
        types[i] = toType(arrObj->m_data[i]);
    }
    ArrayRef<llvm::Type*> elems(types, len);
    auto type = StructType::create(*toLLVMContext(ctxObj),
        elems, string_to_ref(nameObj), isPacked);
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to a opaque struct type with the given name.
extern "C" obj_res papyrus_get_opaque_struct_type(
    b_obj_arg nameObj, obj_arg ctxObj, obj_arg /* w */)
{
    auto type = StructType::create(*toLLVMContext(ctxObj), string_to_ref(nameObj));
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

// Get a reference to the literal struct type with the given elements and packing.
extern "C" obj_res papyrus_get_literal_struct_type(
    b_obj_arg elemsObj, uint8_t isPacked, obj_arg ctxObj, obj_arg /* w */)
{
    lean_array_object* arrObj = lean_to_array(elemsObj);
    size_t len = arrObj->m_size;
    llvm::Type* types[len];
    for (size_t i = 0; i < len; i++) {
        types[i] = toType(arrObj->m_data[i]);
    }
    ArrayRef<llvm::Type*> elems(types, len);
    auto type = StructType::get(*toLLVMContext(ctxObj), elems, isPacked);
    return io_result_mk_ok(mk_type_ref(ctxObj, type));
}

} // end namespace papyrus
