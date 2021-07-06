#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/io.h>
#include <llvm/IR/Constants.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// Get the LLVM Constant pointer wrapped in an object.
llvm::Constant* toConstant(lean::object* ref) {
	return llvm::cast<Constant>(toValue(ref));
}

//------------------------------------------------------------------------------
// Generic Constants
//------------------------------------------------------------------------------

// Get the null constant of the given type.
extern "C" obj_res papyrus_get_null_constant(b_obj_arg typeRef, obj_arg /* w */) {
	auto constant = Constant::getNullValue(toType(typeRef));
	return io_result_mk_ok(mkValueRef(shareLink(typeRef), constant));
}

// Get the all ones constant of the given type.
extern "C" obj_res papyrus_get_all_ones_constant(b_obj_arg typeRef, obj_arg /* w */) {
	auto constant = Constant::getAllOnesValue(toType(typeRef));
	return io_result_mk_ok(mkValueRef(shareLink(typeRef), constant));
}

//------------------------------------------------------------------------------
// Constant Words / Integers / Naturals
//------------------------------------------------------------------------------

// Get the LLVM ConstantInt pointer wrapped in an object.
llvm::ConstantInt* toConstantInt(lean::object* ref) {
	return llvm::cast<ConstantInt>(toValue(ref));
}

// Get a reference to an i1 constant of the given Bool value.
extern "C" obj_res papyrus_get_constant_bool
(uint8 val, obj_arg ctxObj, obj_arg /* w */)
{
	auto n = ConstantInt::getBool(*toLLVMContext(ctxObj), val);
	return io_result_mk_ok(mkValueRef(ctxObj, n));
}

// Get a reference to an i8 constant of the given UInt8 value.
extern "C" obj_res papyrus_get_constant_uint8
(uint8 val, obj_arg ctxObj, obj_arg /* w */)
{
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), APInt(8, val));
	return io_result_mk_ok(mkValueRef(ctxObj, n));
}

// Get a reference to an i16 constant of the given UInt16 value.
extern "C" obj_res papyrus_get_constant_uint16
(uint16 val, obj_arg ctxObj, obj_arg /* w */)
{
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), APInt(16, val));
	return io_result_mk_ok(mkValueRef(ctxObj, n));
}

// Get a reference to an i32 constant of the given UInt32 value.
extern "C" obj_res papyrus_get_constant_uint32
(uint32 val, obj_arg ctxObj, obj_arg /* w */)
{
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), APInt(32, val));
	return io_result_mk_ok(mkValueRef(ctxObj, n));
}

// Get a reference to an i64 constant of the given UInt64 value.
extern "C" obj_res papyrus_get_constant_uint64
(uint64 val, obj_arg ctxObj, obj_arg /* w */)
{
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), APInt(64, val));
	return io_result_mk_ok(mkValueRef(ctxObj, n));
}

// Get a reference to a constant of the given Int value,
// truncating and/or extending it as necessary to fit in the given type.
extern "C" obj_res papyrus_get_constant_int
(b_obj_arg intObj, b_obj_arg typeRef, obj_arg /* w */)
{
	auto ctxObj = shareLink(typeRef);
	auto numBits = toIntegerType(typeRef)->getBitWidth();
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), apOfInt(numBits, intObj));
	return io_result_mk_ok(mkValueRef(ctxObj, n));
}

// Get a reference to a constant of the given Nat value,
// truncating and/or extending it as necessary to fit in the given type.
extern "C" obj_res papyrus_get_constant_nat
(b_obj_arg intObj, b_obj_arg typeRef, obj_arg /* w */)
{
	auto ctxObj = shareLink(typeRef);
	auto numBits = toIntegerType(typeRef)->getBitWidth();
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), apOfNat(numBits, intObj));
	return io_result_mk_ok(mkValueRef(ctxObj, n));
}

// Get the Int value of the given integer constant.
extern "C" obj_res papyrus_constant_word_get_int_value(b_obj_arg constRef, obj_arg /* w */) {
	return io_result_mk_ok(mkIntFromAP(toConstantInt(constRef)->getValue()));
}

// Get the Nat value of the given integer constant.
extern "C" obj_res papyrus_constant_word_get_nat_value(b_obj_arg constRef, obj_arg /* w */) {
	return io_result_mk_ok(mkNatFromAP(toConstantInt(constRef)->getValue()));
}

//------------------------------------------------------------------------------
// Constant Data Arrays
//------------------------------------------------------------------------------

// Get the LLVM ConstantDataSequential pointer wrapped in an object.
ConstantDataSequential* toConstantDataSequential(lean::object* ref) {
	return llvm::cast<ConstantDataSequential>(toValue(ref));
}

// Get whether this constant is a string.
extern "C" obj_res papyrus_constant_data_sequential_is_string
	(b_obj_arg constRef,  obj_arg /* w */)
{
	auto b = toConstantDataSequential(constRef)->isString();
	return io_result_mk_ok(box(b));
}

// Get the value of a constant as a string by treating its bytes as characters.
extern "C" obj_res papyrus_constant_data_sequential_get_as_string
	(b_obj_arg constRef, uint8 withNull, obj_arg /* w */)
{
	auto str = toConstantDataSequential(constRef)->getRawDataValues();
	return io_result_mk_ok(mkStringFromRef(str));
}

// Get a reference to a (UTF-8 encoded) string constant.
extern "C" obj_res papyrus_get_constant_string
(b_obj_arg strObj, uint8 withNull, obj_arg ctxObj, obj_arg /* w */)
{
	auto str = withNull ? refOfStringWithNull(strObj) : refOfString(strObj);
	auto cnst = ConstantDataArray::getString(*toLLVMContext(ctxObj), str, false);
	return io_result_mk_ok(mkValueRef(ctxObj, cnst));
}

//------------------------------------------------------------------------------
// Constant Expressions
//------------------------------------------------------------------------------

// Get whether this constant is a string.
extern "C" obj_res papyrus_constant_expr_get_element_ptr
	(b_obj_arg aggRef, b_obj_arg indicesObj, uint8 inBounds, obj_arg /* w */)
{
	LEAN_ARRAY_TO_REF(Constant*, toConstant, indicesObj, indices);
	auto k = ConstantExpr::getGetElementPtr(nullptr, toConstant(aggRef),
		indices, inBounds);
	return io_result_mk_ok(mkValueRef(getValueContext(aggRef), k));
}

// Get the value of a constant as a string by treating its bytes as characters.
extern "C" obj_res papyrus_constant_expr_get_element_ptr_in_range
	(b_obj_arg aggRef, b_obj_arg indicesObj, uint32 inRange,
		uint8 inBounds, obj_arg /* w */)
{
	LEAN_ARRAY_TO_REF(Constant*, toConstant, indicesObj, indices);
	auto k = ConstantExpr::getGetElementPtr(nullptr, toConstant(aggRef),
		indices, inBounds, inRange);
	return io_result_mk_ok(mkValueRef(getValueContext(aggRef), k));
}

// Get a reference to a (UTF-8 encoded) string constan

} // end namespace papyrus
