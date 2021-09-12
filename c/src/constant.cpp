#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/IR/Constants.h>

using namespace llvm;

namespace papyrus {

// Wrap an LLVM Constant pointer in an Lean object.
lean_obj_res mkConstantRef(lean_obj_arg ctxRef, llvm::Constant* ptr) {
	return mkValueRef(ctxRef, ptr);
}

// Get the LLVM Constant pointer wrapped in an object.
llvm::Constant* toConstant(lean_object* ref) {
	return llvm::cast<Constant>(toValue(ref));
}

//------------------------------------------------------------------------------
// Generic Constants
//------------------------------------------------------------------------------

// Get the null constant of the given type.
extern "C" lean_obj_res papyrus_get_null_constant
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto constant = Constant::getNullValue(toType(typeRef));
	return lean_io_result_mk_ok(mkConstantRef(copyLink(typeRef), constant));
}

// Get the all ones constant of the given type.
extern "C" lean_obj_res papyrus_get_all_ones_constant
	(b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto constant = Constant::getAllOnesValue(toType(typeRef));
	return lean_io_result_mk_ok(mkConstantRef(copyLink(typeRef), constant));
}

//------------------------------------------------------------------------------
// Constant Ints (Words / Integers / Naturals)
//------------------------------------------------------------------------------

// Get the LLVM ConstantInt pointer wrapped in an object.
llvm::ConstantInt* toConstantInt(lean_object* ref) {
	return llvm::cast<ConstantInt>(toValue(ref));
}

// Get a reference to an LLVM true constant (`i1 0`).
extern "C" lean_obj_res papyrus_get_constant_false
	(lean_obj_arg ctxObj, lean_obj_arg /* w */)
{
	auto n = ConstantInt::getFalse(*toLLVMContext(ctxObj));
	return lean_io_result_mk_ok(mkConstantRef(ctxObj, n));
}

// Get a reference to an LLVM true constant (`i1 1`).
extern "C" lean_obj_res papyrus_get_constant_true
	(lean_obj_arg ctxObj, lean_obj_arg /* w */)
{
	auto n = ConstantInt::getTrue(*toLLVMContext(ctxObj));
	return lean_io_result_mk_ok(mkConstantRef(ctxObj, n));
}

// Get a reference to an i1 constant of the given Bool value.
extern "C" lean_obj_res papyrus_get_constant_bool
	(uint8_t val, lean_obj_arg ctxObj, lean_obj_arg /* w */)
{
	auto n = ConstantInt::getBool(*toLLVMContext(ctxObj), val);
	return lean_io_result_mk_ok(mkConstantRef(ctxObj, n));
}

// Get a reference to an i8 constant of the given UInt8 value.
extern "C" lean_obj_res papyrus_get_constant_uint8
	(uint8_t val, lean_obj_arg ctxObj, lean_obj_arg /* w */)
{
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), APInt(8, val));
	return lean_io_result_mk_ok(mkConstantRef(ctxObj, n));
}

// Get a reference to an i16 constant of the given UInt16 value.
extern "C" lean_obj_res papyrus_get_constant_uint16
	(uint16_t val, lean_obj_arg ctxObj, lean_obj_arg /* w */)
{
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), APInt(16, val));
	return lean_io_result_mk_ok(mkConstantRef(ctxObj, n));
}

// Get a reference to an i32 constant of the given UInt32 value.
extern "C" lean_obj_res papyrus_get_constant_uint32
	(uint32_t val, lean_obj_arg ctxObj, lean_obj_arg /* w */)
{
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), APInt(32, val));
	return lean_io_result_mk_ok(mkConstantRef(ctxObj, n));
}

// Get a reference to an i64 constant of the given UInt64 value.
extern "C" lean_obj_res papyrus_get_constant_uint64
	(uint64_t val, lean_obj_arg ctxObj, lean_obj_arg /* w */)
{
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), APInt(64, val));
	return lean_io_result_mk_ok(mkConstantRef(ctxObj, n));
}

// Get a reference to a constant of the given Nat value truncated to `numBits`.
extern "C" lean_obj_res papyrus_get_constant_nat_of_size
	(uint32_t numBits, b_lean_obj_res intObj, lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto n = ConstantInt::get(*toLLVMContext(ctxRef), apOfNat(numBits, intObj));
	return lean_io_result_mk_ok(mkConstantRef(ctxRef, n));
}

// Get a reference to a constant of the given Nat value,
// truncating and/or extending it as necessary to fit in the given type.
extern "C" lean_obj_res papyrus_get_constant_nat_of_type
	(b_lean_obj_res intObj, b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto ctxRef = copyLink(typeRef);
	auto numBits = toIntegerType(typeRef)->getBitWidth();
	auto n = ConstantInt::get(*toLLVMContext(ctxRef), apOfNat(numBits, intObj));
	return lean_io_result_mk_ok(mkConstantRef(ctxRef, n));
}

// Get a reference to a constant of the given Int value truncated to `numBits`.
extern "C" lean_obj_res papyrus_get_constant_int_of_size
	(uint32_t numBits, b_lean_obj_res intObj, lean_obj_arg ctxRef, lean_obj_arg /* w */)
{
	auto n = ConstantInt::get(*toLLVMContext(ctxRef), apOfInt(numBits, intObj));
	return lean_io_result_mk_ok(mkConstantRef(ctxRef, n));
}

// Get a reference to a constant of the given Int value,
// truncating and/or extending it as necessary to fit in the given type.
extern "C" lean_obj_res papyrus_get_constant_int_of_type
	(b_lean_obj_res intObj, b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto ctxObj = copyLink(typeRef);
	auto numBits = toIntegerType(typeRef)->getBitWidth();
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), apOfInt(numBits, intObj));
	return lean_io_result_mk_ok(mkConstantRef(ctxObj, n));
}

// Get the Nat value of the given integer constant.
extern "C" lean_obj_res papyrus_constant_int_get_nat_value
	(b_lean_obj_res constRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(mkNatFromAP(toConstantInt(constRef)->getValue()));
}

// Get the Int value of the given integer constant.
extern "C" lean_obj_res papyrus_constant_int_get_int_value
	(b_lean_obj_res constRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(mkIntFromAP(toConstantInt(constRef)->getValue()));
}

//------------------------------------------------------------------------------
// Constant Data Arrays
//------------------------------------------------------------------------------

// Get the LLVM ConstantDataSequential pointer wrapped in an object.
ConstantDataSequential* toConstantDataSequential(lean_object* ref) {
	return llvm::cast<ConstantDataSequential>(toValue(ref));
}

// Get whether this constant is a string.
extern "C" lean_obj_res papyrus_constant_data_sequential_is_string
	(b_lean_obj_res constRef,  lean_obj_arg /* w */)
{
	auto b = toConstantDataSequential(constRef)->isString();
	return lean_io_result_mk_ok(lean_box(b));
}

// Get the value of a constant as a string by treating its bytes as characters.
extern "C" lean_obj_res papyrus_constant_data_sequential_get_as_string
	(b_lean_obj_res constRef, uint8_t withNull, lean_obj_arg /* w */)
{
	auto str = toConstantDataSequential(constRef)->getRawDataValues();
	return lean_io_result_mk_ok(mkStringFromRef(str));
}

// Get a reference to a (UTF-8 encoded) string constant.
extern "C" lean_obj_res papyrus_get_constant_string
(b_lean_obj_res strObj, uint8_t withNull, lean_obj_arg ctxObj, lean_obj_arg /* w */)
{
	auto str = withNull ? refOfStringWithNull(strObj) : refOfString(strObj);
	auto cnst = ConstantDataArray::getString(*toLLVMContext(ctxObj), str, false);
	return lean_io_result_mk_ok(mkConstantRef(ctxObj, cnst));
}

//------------------------------------------------------------------------------
// Constant Expressions
//------------------------------------------------------------------------------

// Get a reference to a constant GEP expression.
extern "C" lean_obj_res papyrus_constant_expr_get_element_ptr
	(b_lean_obj_res aggRef, b_lean_obj_res indicesObj, uint8_t inBounds,
		lean_obj_arg /* w */)
{
	LEAN_ARRAY_TO_REF(Constant*, toConstant, indicesObj, indices);
	auto k = ConstantExpr::getGetElementPtr(nullptr, toConstant(aggRef),
		indices, inBounds);
	return lean_io_result_mk_ok(mkConstantRef(getValueContext(aggRef), k));
}

// Get a reference to a constant GEP expression with an additional `inrange` index.
extern "C" lean_obj_res papyrus_constant_expr_get_element_ptr_in_range
	(b_lean_obj_res aggRef, b_lean_obj_res indicesObj, uint32_t inRange,
		uint8_t inBounds, lean_obj_arg /* w */)
{
	LEAN_ARRAY_TO_REF(Constant*, toConstant, indicesObj, indices);
	auto k = ConstantExpr::getGetElementPtr(nullptr, toConstant(aggRef),
		indices, inBounds, inRange);
	return lean_io_result_mk_ok(mkConstantRef(getValueContext(aggRef), k));
}

// Get a reference to a constant `ptrtoint` expression.
extern "C" lean_obj_res papyrus_constant_expr_get_ptr_to_int
	(b_lean_obj_res constRef, b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto k = ConstantExpr::getPtrToInt(toConstant(constRef), toType(typeRef));
	return lean_io_result_mk_ok(mkConstantRef(getValueContext(constRef), k));
}

// Get a reference to a constant `inttoptr` expression.
extern "C" lean_obj_res papyrus_constant_expr_get_int_to_ptr
	(b_lean_obj_res constRef, b_lean_obj_res typeRef, lean_obj_arg /* w */)
{
	auto k = ConstantExpr::getIntToPtr(toConstant(constRef), toType(typeRef));
	return lean_io_result_mk_ok(mkConstantRef(getValueContext(constRef), k));
}

} // end namespace papyrus
