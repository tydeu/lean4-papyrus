#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/Support/TypeSize.h>
#include <llvm/ADT/APFloat.h>

using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// Type references
//------------------------------------------------------------------------------

// Wrap an LLVM Type pointer in a Lean object.
lean_obj_res mkTypeRef(lean_obj_arg ctxRef, llvm::Type* ptr) {
	return mkLinkedLoosePtr<llvm::Type>(ctxRef, ptr);
}

// Get the LLVM Type pointer wrapped in an object.
llvm::Type* toType(b_lean_obj_res typeRef) {
	return fromLinkedLoosePtr<llvm::Type>(typeRef);
}

// Covert an LLVM ArrayRef of types to a Lean Array of type references.
lean_obj_res packTypes
	(b_lean_obj_res ctxRef, const llvm::ArrayRef<llvm::Type*>& arr)
{
	size_t len = arr.size();
	lean_object* obj = lean_alloc_array(len, len);
	lean_array_object* arrObj = lean_to_array(obj);
	for (size_t i = 0; i < len; i++) {
		lean_inc_ref(ctxRef);
		arrObj->m_data[i] = mkTypeRef(ctxRef, arr[i]);
	}
	return obj;
}

// Covert a Lean Array of type references to an LLVM ArrayRef of types.
// Defined as a macro because it needs to dynamically allocate to the user's stack.
#define PAPYRUS_UNPACK_TYPES(OBJ, REF) LEAN_ARRAY_TO_REF(llvm::Type*, toType, OBJ, REF)

//------------------------------------------------------------------------------
// Basic functions
//------------------------------------------------------------------------------

// Get the owning LLVM context object of the given type (in Lean).
extern "C" lean_obj_res papyrus_type_get_context
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(copyLink(typeRef));
}

// Get the TypeID of the given type.
// As a type's ID is immutable, we don't need to wrap it in IO.
extern "C" uint8_t papyrus_type_id
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	return toType(typeRef)->getTypeID();
}

// Print the given type to LLVM's standard output.
extern "C" lean_obj_res papyrus_type_print
	(b_lean_obj_res typeRef, uint8_t isForDebug, lean_obj_arg /* w */)
{
	toType(typeRef)->print(llvm::outs(), isForDebug);
	return lean_io_result_mk_ok(lean_box(0));
}

// Print the given type to LLVM's standard error.
extern "C" lean_obj_res papyrus_type_eprint
	(b_lean_obj_res typeRef, uint8_t isForDebug, lean_obj_arg /* w */)
{
	toType(typeRef)->print(llvm::errs(), isForDebug);
	return lean_io_result_mk_ok(lean_box(0));
}

// Print the given type to a string.
extern "C" lean_obj_res papyrus_type_sprint
	(b_lean_obj_res typeRef, uint8_t isForDebug, lean_obj_arg /* w */)
{
	std::string ostr;
	raw_string_ostream out(ostr);
	toType(typeRef)->print(out, isForDebug);
	return lean_io_result_mk_ok(mkStringFromStd(out.str()));
}

//------------------------------------------------------------------------------
// Special types
//------------------------------------------------------------------------------

// Get a reference to the Void type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_void_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getVoidTy(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the Label type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_label_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getLabelTy(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the Metadata type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_metadata_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getMetadataTy(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the Token type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_token_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getTokenTy(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the X86_MMX type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_x86_mmx_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getX86_MMXTy(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the X86_AMX type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_x86_amx_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getX86_AMXTy(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

//------------------------------------------------------------------------------
// Floating point types
//------------------------------------------------------------------------------

// Get a reference to the Half type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_half_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getHalfTy(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the BFloat type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_bfloat_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getBFloatTy(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the Float type  for the given LLVM context.
extern "C" lean_obj_res papyrus_get_float_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getFloatTy(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the Double type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_double_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getDoubleTy(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the X86_FP80 type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_x86_fp80_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getX86_FP80Ty(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the FP128 type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_fp128_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getFP128Ty(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to the PPC_FP128 type for the given LLVM context.
extern "C" lean_obj_res papyrus_get_ppc_fp128_type
	(lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = llvm::Type::getPPC_FP128Ty(*toLLVMContext(ctxRef));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

//------------------------------------------------------------------------------
// Integer types
//------------------------------------------------------------------------------

// Get the LLVM IntegerType pointer wrapped in an object.
llvm::IntegerType* toIntegerType(b_lean_obj_res typeRef) {
	return llvm::cast<IntegerType>(toType(typeRef));
}

// Get the width in bits of the given integer type.
extern "C" lean_obj_res papyrus_integer_type_get_bit_width
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toIntegerType(typeRef)->getBitWidth()));
}

// Get a reference to the integer type of the given bit width
// for the given LLVM context.
extern "C" lean_obj_res papyrus_get_integer_type(
	uint32_t numBits, lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = IntegerType::get(*toLLVMContext(ctxRef), numBits);
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

//------------------------------------------------------------------------------
// Function types
//------------------------------------------------------------------------------

// Get the LLVM IntegerType pointer wrapped in an object.
llvm::FunctionType* toFunctionType(b_lean_obj_res typeRef) {
	return llvm::cast<FunctionType>(toType(typeRef));
}

// Get a reference to the function type with the given parameters and result.
extern "C" lean_obj_res papyrus_get_function_type
	(b_lean_obj_res resultObj, b_lean_obj_res paramsObj, uint8_t isVarArg,
		lean_obj_arg /* w */)
{
	PAPYRUS_UNPACK_TYPES(paramsObj, params);
	auto type = FunctionType::get(toType(resultObj), params, isVarArg);
	return lean_io_result_mk_ok(mkTypeRef(copyLink(resultObj), type));
}

// Get a reference to the return type of the given function type.
extern "C" lean_obj_res papyrus_function_type_get_return_type
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto retType = toFunctionType(typeRef)->getReturnType();
	return lean_io_result_mk_ok(mkTypeRef(copyLink(typeRef), retType));
}

// Get an array of references to the parameter types of the given function type.
extern "C" lean_obj_res papyrus_function_type_get_parameter_types
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto paramTypes = toFunctionType(typeRef)->params();
	return lean_io_result_mk_ok(packTypes(borrowLink(typeRef), paramTypes));
}

// Get whether the function type reference accpets variable arguments.
extern "C" lean_obj_res papyrus_function_type_is_var_arg
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toFunctionType(typeRef)->isVarArg()));
}

//------------------------------------------------------------------------------
// Pointer types
//------------------------------------------------------------------------------

// Get the LLVM PointerType pointer wrapped in an object.
llvm::PointerType* toPointerType(b_lean_obj_res typeRef) {
	return llvm::cast<PointerType>(toType(typeRef));
}

// Get a reference to the pointer type
// to the given pointee type in the given address space.
extern "C" lean_obj_res papyrus_get_pointer_type
(b_lean_obj_res pointeeObj, uint32_t addrSpace, lean_obj_arg /* w */)
{
	auto type = PointerType::get(toType(pointeeObj), addrSpace);
	return lean_io_result_mk_ok(mkTypeRef(copyLink(pointeeObj), type));
}

// Get a reference to the pointee type of the given pointer type.
extern "C" lean_obj_res papyrus_pointer_type_get_pointee_type
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto retType = toPointerType(typeRef)->getElementType();
	return lean_io_result_mk_ok(mkTypeRef(copyLink(typeRef), retType));
}

// Get the index of the address space of the given pointer type.
extern "C" lean_obj_res papyrus_pointer_type_get_address_space
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto addrSpace = toPointerType(typeRef)->getAddressSpace();
	return lean_io_result_mk_ok(lean_box_uint32(addrSpace));
}

//------------------------------------------------------------------------------
// Struct types
//------------------------------------------------------------------------------

// Get the LLVM StructType pointer wrapped in an object.
llvm::StructType* toStructType(b_lean_obj_res typeRef) {
	return llvm::cast<StructType>(toType(typeRef));
}

// Get a reference to the struct type with the given name (if it exists).
extern "C" lean_obj_res papyrus_struct_type_get_type_by_name
	(b_lean_obj_res nameObj, lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = StructType::getTypeByName(*toLLVMContext(ctxRef), refOfString(nameObj));
	auto obj = type == nullptr ? lean_box(0) : mkSome(mkTypeRef(ctxRef, type));
	return lean_io_result_mk_ok(obj);
}

// Get a reference to the literal struct type with the given elements and packing.
extern "C" lean_obj_res papyrus_get_literal_struct_type
	(b_lean_obj_res elemsObj, uint8_t isPacked, lean_obj_arg ctxRef,
		lean_obj_arg /* w */)
{
	PAPYRUS_UNPACK_TYPES(elemsObj, elems);
	auto type = StructType::get(*toLLVMContext(ctxRef), elems, isPacked);
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to a new opaque struct type with the given name
// (or none if the name string is empty).
extern "C" lean_obj_res papyrus_opaque_struct_type_create
	(b_lean_obj_res nameObj, lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto type = StructType::create(*toLLVMContext(ctxRef), refOfString(nameObj));
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get a reference to a new complete struct type with the given elements and packing.
// The type is uniquely identified by the given name if the string is nonempty.
extern "C" lean_obj_res papyrus_struct_type_create
	(b_lean_obj_res nameObj, b_lean_obj_res elemsObj, uint8_t isPacked,
		lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	PAPYRUS_UNPACK_TYPES(elemsObj, elems);
	auto type = StructType::create(*toLLVMContext(ctxRef),
		elems, refOfString(nameObj), isPacked);
	return lean_io_result_mk_ok(mkTypeRef(ctxRef, type));
}

// Get whether the given struct type is literal.
// As this property is immutable, we don't need to wrap it in IO.
extern "C" uint8_t papyrus_struct_type_is_literal
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	return toStructType(typeRef)->isLiteral();
}

// Get whether the given struct type is non-literal and opaque.
extern "C" lean_obj_res papyrus_struct_type_is_opaque
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toStructType(typeRef)->isOpaque()));
}

// Get the name of the given *non-literal* struct type (or the empty string if none).
extern "C" lean_obj_res papyrus_struct_type_get_name
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(mkStringFromRef(toStructType(typeRef)->getName()));
}

// Set the name of the given *non-literal* struct type to given string.
// An empty string will remove an the existing name.
// The name may also have a suffix appended if it a collides with another
// in the same context.
extern "C" lean_obj_res papyrus_struct_type_set_name
(b_lean_obj_res nameObj, b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	toStructType(typeRef)->setName(refOfString(nameObj));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get an array of references to the element types of the given struct type.
extern "C" lean_obj_res papyrus_struct_type_get_element_types
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto elementTypes = toStructType(typeRef)->elements();
	return lean_io_result_mk_ok(packTypes(borrowLink(typeRef), elementTypes));
}

// Get whether the given struct type is packed.
extern "C" lean_obj_res papyrus_struct_type_is_packed
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toStructType(typeRef)->isPacked()));
}

// Set the body for an opaque struct type, turning it into a complete struct type.
extern "C" lean_obj_res papyrus_opaque_struct_type_set_body
	(b_lean_obj_res elemsObj, uint8_t isPacked, b_lean_obj_res typeRef,
		lean_obj_arg /* w */)
{
	PAPYRUS_UNPACK_TYPES(elemsObj, elems);
	toStructType(typeRef)->setBody(elems, isPacked);
	return lean_io_result_mk_ok(lean_box(0));
}

//------------------------------------------------------------------------------
// Array types
//------------------------------------------------------------------------------

// Get the LLVM ArrayType pointer wrapped in an object.
llvm::ArrayType* toArrayType(b_lean_obj_res typeRef) {
	return llvm::cast<ArrayType>(toType(typeRef));
}

// Get a reference to the array type
// with the given element type and the given number of elements.
extern "C" lean_obj_res papyrus_get_array_type(
	b_lean_obj_res elemTypeRef, uint64_t numElems, lean_obj_arg /* w */)
{
	auto type = ArrayType::get(toType(elemTypeRef), numElems);
	return lean_io_result_mk_ok(mkTypeRef(copyLink(elemTypeRef), type));
}

// Get a reference to the element type of the given array type.
extern "C" lean_obj_res papyrus_array_type_get_element_type
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto retType = toArrayType(typeRef)->getElementType();
	return lean_io_result_mk_ok(mkTypeRef(copyLink(typeRef), retType));
}

// Get the number of elements of the given array type.
extern "C" lean_obj_res papyrus_array_type_get_num_elements
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto n = toArrayType(typeRef)->getNumElements();
	return lean_io_result_mk_ok(lean_box_uint64(n));
}

//------------------------------------------------------------------------------
// Vector types
//------------------------------------------------------------------------------

// Get the LLVM VectorType pointer wrapped in an object.
llvm::VectorType* toVectorType(b_lean_obj_res typeRef) {
	return llvm::cast<VectorType>(toType(typeRef));
}

// Get a reference to the fixed vector type with the given element type and size.
extern "C" lean_obj_res papyrus_get_fixed_vector_type(
	b_lean_obj_res elemTypeRef, uint32_t numElems, lean_obj_arg /* w */)
{
	auto type = FixedVectorType::get(toType(elemTypeRef), numElems);
	return lean_io_result_mk_ok(mkTypeRef(copyLink(elemTypeRef), type));
}

// Get a reference to the scalable vector type with the given element type and min size.
extern "C" lean_obj_res papyrus_get_scalable_vector_type(
	b_lean_obj_res elemTypeRef, uint32_t minNumElems, lean_obj_arg /* w */)
{
	auto type = ScalableVectorType::get(toType(elemTypeRef), minNumElems);
	return lean_io_result_mk_ok(mkTypeRef(copyLink(elemTypeRef), type));
}

// Get a reference to the element type of the given vector type.
extern "C" lean_obj_res papyrus_vector_type_get_element_type
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto retType = toVectorType(typeRef)->getElementType();
	return lean_io_result_mk_ok(mkTypeRef(copyLink(typeRef), retType));
}

// Get the number of element quantity of the given vector type.
extern "C" lean_obj_res papyrus_vector_type_get_element_quantity
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto q = toVectorType(typeRef)->getElementCount().getKnownMinValue();
	return lean_io_result_mk_ok(lean_box_uint32(q));
}

} // end namespace papyrus
