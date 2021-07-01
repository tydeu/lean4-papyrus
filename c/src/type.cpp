#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/io.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/Support/TypeSize.h>
#include <llvm/ADT/APFloat.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// Type references
//------------------------------------------------------------------------------

// Wrap an LLVM Type pointer in a Lean object.
lean::object* mkTypeRef(lean::object* ctx, llvm::Type* ptr) {
	return mkLinkedLoosePtr<llvm::Type>(ctx, ptr);
}

// Get the LLVM Type pointer wrapped in an object.
llvm::Type* toType(lean::object* typeRef) {
	return fromLinkedLoosePtr<llvm::Type>(typeRef);
}

// Covert an LLVM ArrayRef of types to a Lean Array of type references.
lean::object* packTypes(b_obj_arg ctxRef, const llvm::ArrayRef<llvm::Type*>& arr) {
	size_t len = arr.size();
	lean_object* obj = lean::alloc_array(len, len);
	lean_array_object* arrObj = lean_to_array(obj);
	for (size_t i = 0; i < len; i++) {
		lean_inc_ref(ctxRef);
		arrObj->m_data[i] = mkTypeRef(ctxRef, arr[i]);
	}
	return obj;
}

// Covert a Lean Array of type references to an LLVM ArrayRef of types.
// Defined as a macro because it needs to dynamically allocate to the user's stack.
#define LEAN_UNPACK_TYPES(OBJ, REF) LEAN_ARRAY_TO_REF(Type*, toType, OBJ, REF)

//------------------------------------------------------------------------------
// Basic functions
//------------------------------------------------------------------------------

// Get the owning LLVM context object of the given type (in Lean).
extern "C" obj_res papyrus_type_get_context(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(shareLink(typeRef));
}

// Get the TypeID of the given type.
extern "C" obj_res papyrus_type_get_id(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(box(toType(typeRef)->getTypeID()));
}

//------------------------------------------------------------------------------
// Special types
//------------------------------------------------------------------------------

// Get a reference to the Void type for the given LLVM context.
extern "C" obj_res papyrus_get_void_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getVoidTy(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the Label type for the given LLVM context.
extern "C" obj_res papyrus_get_label_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getLabelTy(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the Metadata type for the given LLVM context.
extern "C" obj_res papyrus_get_metadata_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getMetadataTy(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the Token type for the given LLVM context.
extern "C" obj_res papyrus_get_token_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getTokenTy(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the X86_MMX type for the given LLVM context.
extern "C" obj_res papyrus_get_x86_mmx_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getX86_MMXTy(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the X86_AMX type for the given LLVM context.
extern "C" obj_res papyrus_get_x86_amx_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getX86_AMXTy(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

//------------------------------------------------------------------------------
// Floating point types
//------------------------------------------------------------------------------

// Get a reference to the Half type for the given LLVM context.
extern "C" obj_res papyrus_get_half_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getHalfTy(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the BFloat type for the given LLVM context.
extern "C" obj_res papyrus_get_bfloat_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getBFloatTy(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the Float type  for the given LLVM context.
extern "C" obj_res papyrus_get_float_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getFloatTy(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the Double type for the given LLVM context.
extern "C" obj_res papyrus_get_double_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getDoubleTy(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the X86_FP80 type for the given LLVM context.
extern "C" obj_res papyrus_get_x86_fp80_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getX86_FP80Ty(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the FP128 type for the given LLVM context.
extern "C" obj_res papyrus_get_fp128_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getFP128Ty(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the PPC_FP128 type for the given LLVM context.
extern "C" obj_res papyrus_get_ppc_fp128_type(obj_arg ctxRef, obj_arg /* w */) {
	auto type = llvm::Type::getPPC_FP128Ty(*toLLVMContext(ctxRef));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

//------------------------------------------------------------------------------
// Integer types
//------------------------------------------------------------------------------

// Get the LLVM IntegerType pointer wrapped in an object.
llvm::IntegerType* toIntegerType(lean::object* typeRef) {
	return llvm::cast<IntegerType>(toType(typeRef));
}

// Get the width in bits of the given integer type.
extern "C" obj_res papyrus_integer_type_get_bit_width(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(box(toIntegerType(typeRef)->getBitWidth()));
}

// Get a reference to the integer type of the given bit width
// for the given LLVM context.
extern "C" obj_res papyrus_get_integer_type(
	uint32_t numBits, obj_arg ctxRef, obj_arg /* w */)
{
	auto type = IntegerType::get(*toLLVMContext(ctxRef), numBits);
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

//------------------------------------------------------------------------------
// Function types
//------------------------------------------------------------------------------

// Get the LLVM IntegerType pointer wrapped in an object.
llvm::FunctionType* toFunctionType(lean::object* typeRef) {
	return llvm::cast<FunctionType>(toType(typeRef));
}

// Get a reference to the function type with the given parameters and result.
extern "C" obj_res papyrus_get_function_type
(b_obj_arg resultObj, b_obj_arg paramsObj, uint8_t isVarArg, obj_arg /* w */)
{
	LEAN_UNPACK_TYPES(paramsObj, params);
	auto type = FunctionType::get(toType(resultObj), params, isVarArg);
	return io_result_mk_ok(mkTypeRef(shareLink(resultObj), type));
}

// Get a reference to the return type of the given function type.
extern "C" obj_res papyrus_function_type_get_return_type(b_obj_arg typeRef, obj_arg /* w */) {
	auto retType = toFunctionType(typeRef)->getReturnType();
	return io_result_mk_ok(mkTypeRef(shareLink(typeRef), retType));
}

// Get an array of references to the parameter types of the given function type.
extern "C" obj_res papyrus_function_type_get_parameter_types(b_obj_arg typeRef, obj_arg /* w */) {
	auto paramTypes = toFunctionType(typeRef)->params();
	return io_result_mk_ok(packTypes(borrowLink(typeRef), paramTypes));
}

// Get whether the function type reference accpets variable arguments.
extern "C" obj_res papyrus_function_type_is_var_arg(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(box(toFunctionType(typeRef)->isVarArg()));
}

//------------------------------------------------------------------------------
// Pointer types
//------------------------------------------------------------------------------

// Get the LLVM PointerType pointer wrapped in an object.
llvm::PointerType* toPointerType(lean::object* typeRef) {
	return llvm::cast<PointerType>(toType(typeRef));
}

// Get a reference to the pointer type
// to the given pointee type in the given address space.
extern "C" obj_res papyrus_get_pointer_type
(b_obj_arg pointeeObj, uint32_t addrSpace, obj_arg /* w */)
{
	auto type = PointerType::get(toType(pointeeObj), addrSpace);
	return io_result_mk_ok(mkTypeRef(shareLink(pointeeObj), type));
}

// Get a reference to the pointee type of the given pointer type.
extern "C" obj_res papyrus_pointer_type_get_pointee_type(b_obj_arg typeRef, obj_arg /* w */) {
	auto retType = toPointerType(typeRef)->getElementType();
	return io_result_mk_ok(mkTypeRef(shareLink(typeRef), retType));
}

// Get the index of the address space of the given pointer type.
extern "C" obj_res papyrus_pointer_type_get_address_space(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(box_uint32(toPointerType(typeRef)->getAddressSpace()));
}

//------------------------------------------------------------------------------
// Struct types
//------------------------------------------------------------------------------

// Get the LLVM StructType pointer wrapped in an object.
llvm::StructType* toStructType(lean::object* typeRef) {
	return llvm::cast<StructType>(toType(typeRef));
}

// Get a reference to the literal struct type with the given elements and packing.
extern "C" obj_res papyrus_get_literal_struct_type
(b_obj_arg elemsObj, uint8_t isPacked, obj_arg ctxRef, obj_arg /* w */)
{
	LEAN_UNPACK_TYPES(elemsObj, elems);
	auto type = StructType::get(*toLLVMContext(ctxRef), elems, isPacked);
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to a new opaque struct type with the given name
// (or none if the name string is empty).
extern "C" obj_res papyrus_opaque_struct_type_create
(b_obj_arg nameObj, obj_arg ctxRef, obj_arg /* w */)
{
	auto type = StructType::create(*toLLVMContext(ctxRef), refOfString(nameObj));
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to a new complete struct type with the given elements and packing.
// The type is uniquely identified by the given name if the string is nonempty.
extern "C" obj_res papyrus_struct_type_create
(b_obj_arg nameObj, b_obj_arg elemsObj, uint8_t isPacked, obj_arg ctxRef, obj_arg /* w */)
{
	LEAN_UNPACK_TYPES(elemsObj, elems);
	auto type = StructType::create(*toLLVMContext(ctxRef),
		elems, refOfString(nameObj), isPacked);
	return io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get whether the given struct type is literal.
extern "C" obj_res papyrus_struct_type_is_literal(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(box(toStructType(typeRef)->isLiteral()));
}

// Get whether the given struct type is non-literal and opaque.
extern "C" obj_res papyrus_struct_type_is_opaque(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(box(toStructType(typeRef)->isOpaque()));
}

// Get the name of the given *non-literal* struct type (or the empty string if none).
extern "C" obj_res papyrus_struct_type_get_name(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(mkStringFromRef(toStructType(typeRef)->getName()));
}

// Set the name of the given *non-literal* struct type to given string.
// An empty string will remove an the existing name.
// The name may also have a suffix appended if it a collides with another
// in the same context.
extern "C" obj_res papyrus_struct_type_set_name
(b_obj_arg nameObj, b_obj_arg typeRef, obj_arg /* w */)
{
	toStructType(typeRef)->setName(refOfString(nameObj));
	return io_result_mk_ok(box(0));
}

// Get an array of references to the element types of the given struct type.
extern "C" obj_res papyrus_struct_type_get_element_types(b_obj_arg typeRef, obj_arg /* w */) {
	auto elementTypes = toStructType(typeRef)->elements();
	return io_result_mk_ok(packTypes(borrowLink(typeRef), elementTypes));
}

// Get whether the given struct type is packed.
extern "C" obj_res papyrus_struct_type_is_packed(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(box(toStructType(typeRef)->isPacked()));
}

// Set the body for an opaque struct type, turning it into a complete struct type.
extern "C" obj_res papyrus_opaque_struct_type_set_body
(b_obj_arg elemsObj, uint8_t isPacked, b_obj_arg typeRef, obj_arg /* w */)
{
	LEAN_UNPACK_TYPES(elemsObj, elems);
	toStructType(typeRef)->setBody(elems, isPacked);
	return io_result_mk_ok(box(0));
}

//------------------------------------------------------------------------------
// Array types
//------------------------------------------------------------------------------

// Get the LLVM ArrayType pointer wrapped in an object.
llvm::ArrayType* toArrayType(lean::object* typeRef) {
	return llvm::cast<ArrayType>(toType(typeRef));
}

// Get a reference to the array type
// with the given element type and the given number of elements.
extern "C" obj_res papyrus_get_array_type(
	b_obj_arg elemTypeRef, uint64_t numElems, obj_arg /* w */)
{
	auto type = ArrayType::get(toType(elemTypeRef), numElems);
	return io_result_mk_ok(mkTypeRef(shareLink(elemTypeRef), type));
}

// Get a reference to the element type of the given array type.
extern "C" obj_res papyrus_array_type_get_element_type(b_obj_arg typeRef, obj_arg /* w */) {
	auto retType = toArrayType(typeRef)->getElementType();
	return io_result_mk_ok(mkTypeRef(shareLink(typeRef), retType));
}

// Get the number of elements of the given array type.
extern "C" obj_res papyrus_array_type_get_num_elements(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(box_uint64(toArrayType(typeRef)->getNumElements()));
}

//------------------------------------------------------------------------------
// Vector types
//------------------------------------------------------------------------------

// Get the LLVM VectorType pointer wrapped in an object.
llvm::VectorType* toVectorType(lean::object* typeRef) {
	return llvm::cast<VectorType>(toType(typeRef));
}

// Get a reference to the vector type
// with the given element type, element quantity, and scalability.
extern "C" obj_res papyrus_get_vector_type(
	b_obj_arg elemTypeRef, uint32_t numElems, uint8_t isScalable, obj_arg /* w */)
{
	auto type = VectorType::get(toType(elemTypeRef), numElems, isScalable);
	return io_result_mk_ok(mkTypeRef(shareLink(elemTypeRef), type));
}

// Get a reference to the element type of the given vector type.
extern "C" obj_res papyrus_vector_type_get_element_type(b_obj_arg typeRef, obj_arg /* w */) {
	auto retType = toVectorType(typeRef)->getElementType();
	return io_result_mk_ok(mkTypeRef(shareLink(typeRef), retType));
}

// Get the number of element quantity of the given vector type.
extern "C" obj_res papyrus_vector_type_get_element_quantity(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(box_uint32(toVectorType(typeRef)->getElementCount().getKnownMinValue()));
}

// Get whether this vector type is scalable.
extern "C" obj_res papyrus_vector_type_is_scalable(b_obj_arg typeRef, obj_arg /* w */) {
	return io_result_mk_ok(box_uint32(toVectorType(typeRef)->getElementCount().isScalable()));
}

} // end namespace papyrus
