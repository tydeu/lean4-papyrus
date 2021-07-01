#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/ExecutionEngine/GenericValue.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// Lean object class for an LLVM GenericValue.
static external_object_class* getGenericValueClass() {
	// Use static to make this thread safe by static initialization rules.
	static external_object_class* c = registerDeleteClass<GenericValue>();
	return c;
}

// Wrap a GenericValue in a Lean object.
lean::object* mkGenericValueRef(GenericValue* val) {
	return lean_alloc_external(getGenericValueClass(), val);
}

// Get the GenericValue wrapped in an object.
GenericValue* toGenericValue(lean::object* valRef) {
	auto external = lean_to_external(valRef);
	assert(external->m_class == getGenericValueClass());
	return static_cast<GenericValue*>(external->m_data);
}

// Create a new integer GenericValue from an Int and a IntegerType.
extern "C" obj_res papyrus_generic_value_of_int
(b_obj_arg intObj, uint32 bitWidth, obj_arg /* w */)
{
	auto val = new GenericValue();
  val->IntVal = apOfInt(bitWidth, intObj);
	return io_result_mk_ok(mkGenericValueRef(val));
}

// Convert an integer GenericValue to an Int.
extern "C" obj_res papyrus_generic_value_to_int(b_obj_arg valObj, obj_arg /* w */) {
	return io_result_mk_ok(mkIntFromAP(toGenericValue(valObj)->IntVal));
}

// Create a new integer GenericValue from a Nat and a IntegerType.
extern "C" obj_res papyrus_generic_value_of_nat
(b_obj_arg natObj, uint32 bitWidth, obj_arg /* w */)
{
	auto val = new GenericValue();
  val->IntVal = apOfNat(bitWidth, natObj);
	return io_result_mk_ok(mkGenericValueRef(val));
}

// Convert an integer GenericValue to a Nat.
extern "C" obj_res papyrus_generic_value_to_nat(b_obj_arg valObj, obj_arg /* w */) {
	return io_result_mk_ok(mkNatFromAP(toGenericValue(valObj)->IntVal));
}

// Create a new double GenericValue from a Float.
extern "C" obj_res papyrus_generic_value_of_float(double fval, obj_arg /* w */) {
	auto val = new GenericValue();
  val->DoubleVal = fval;
	return io_result_mk_ok(mkGenericValueRef(val));
}

// Convert a double GenericValue to a Float.
extern "C" obj_res papyrus_generic_value_to_float(b_obj_arg valObj, obj_arg /* w */) {
	return io_result_mk_ok(box_float(toGenericValue(valObj)->FloatVal));
}

// Create a new array GenericValue from an Array of generic value references.
extern "C" obj_res papyrus_generic_value_of_array(b_obj_arg valArr, obj_arg /* w */) {
	auto val = new GenericValue();
  auto valArrObj = lean_to_array(valArr);
	auto valArrLen = valArrObj->m_size;
	val->AggregateVal.reserve(valArrLen);
	for (auto i = 0; i < valArrLen; i++) {
		val->AggregateVal[i] = *toGenericValue(valArrObj->m_data[i]);
	}
	return io_result_mk_ok(mkGenericValueRef(val));
}

// Convert a vector GenericValue to an Array of generic value references.
extern "C" obj_res papyrus_generic_value_to_array(b_obj_arg valObj, obj_arg /* w */) {
	auto val = toGenericValue(valObj);
  size_t len = val->AggregateVal.size();
	lean_object* obj = lean::alloc_array(len, len);
	lean_array_object* arrObj = lean_to_array(obj);
	for (auto i = 0; i < len; i++) {
		arrObj->m_data[i] = mkGenericValueRef(new GenericValue(val->AggregateVal[i]));
	}
	return io_result_mk_ok(obj);
}

} // end namespace papyrus
