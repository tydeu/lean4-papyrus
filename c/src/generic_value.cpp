#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/ExecutionEngine/GenericValue.h>

using namespace llvm;

namespace papyrus {

// Wrap a GenericValue in a Lean object.
lean_object* mkGenericValueRef(GenericValue* ptr) {
	return mkOwnedPtr<GenericValue>(ptr);
}

// Get the GenericValue wrapped in an object.
GenericValue* toGenericValue(lean_object* ref) {
	return fromOwnedPtr<GenericValue>(ref);
}

// Create a new integer GenericValue of the given width from an Int.
extern "C" lean_obj_res papyrus_generic_value_of_int
	(uint32_t numBits, b_lean_obj_res intObj, lean_obj_arg /* w */)
{
	auto val = new GenericValue();
  val->IntVal = apOfInt(numBits, intObj);
	return lean_io_result_mk_ok(mkGenericValueRef(val));
}

// Convert an integer GenericValue to an Int.
extern "C" lean_obj_res papyrus_generic_value_to_int
	(b_lean_obj_res valObj, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(mkIntFromAP(toGenericValue(valObj)->IntVal));
}

// Create a new integer GenericValue of the given width from a Nat.
extern "C" lean_obj_res papyrus_generic_value_of_nat
	(uint32_t numBits, b_lean_obj_res natObj, lean_obj_arg /* w */)
{
	auto val = new GenericValue();
  val->IntVal = apOfNat(numBits, natObj);
	return lean_io_result_mk_ok(mkGenericValueRef(val));
}

// Convert an integer GenericValue to a Nat.
extern "C" lean_obj_res papyrus_generic_value_to_nat
	(b_lean_obj_res valObj, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(mkNatFromAP(toGenericValue(valObj)->IntVal));
}

// Create a new double GenericValue from a Float.
extern "C" lean_obj_res papyrus_generic_value_of_float
	(double fval, lean_obj_arg /* w */)
{
	auto val = new GenericValue();
  val->DoubleVal = fval;
	return lean_io_result_mk_ok(mkGenericValueRef(val));
}

// Convert a double GenericValue to a Float.
extern "C" lean_obj_res papyrus_generic_value_to_float
	(b_lean_obj_res valObj, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box_float(toGenericValue(valObj)->FloatVal));
}

// Create a new array GenericValue from an Array of generic value references.
extern "C" lean_obj_res papyrus_generic_value_of_array
	(b_lean_obj_res valArr, lean_obj_arg /* w */)
{
	auto val = new GenericValue();
  auto valArrObj = lean_to_array(valArr);
	auto valArrLen = valArrObj->m_size;
	val->AggregateVal.reserve(valArrLen);
	for (auto i = 0; i < valArrLen; i++) {
		val->AggregateVal[i] = *toGenericValue(valArrObj->m_data[i]);
	}
	return lean_io_result_mk_ok(mkGenericValueRef(val));
}

// Convert a vector GenericValue to an Array of generic value references.
extern "C" lean_obj_res papyrus_generic_value_to_array
	(b_lean_obj_res valObj, lean_obj_arg /* w */)
{
	auto val = toGenericValue(valObj);
  size_t len = val->AggregateVal.size();
	lean_object* obj = lean_alloc_array(len, len);
	lean_array_object* arrObj = lean_to_array(obj);
	for (auto i = 0; i < len; i++) {
		arrObj->m_data[i] = mkGenericValueRef(new GenericValue(val->AggregateVal[i]));
	}
	return lean_io_result_mk_ok(obj);
}

} // end namespace papyrus
