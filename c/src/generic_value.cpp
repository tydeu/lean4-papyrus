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
lean::object* mk_generic_value(GenericValue* val) {
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
(b_obj_arg intObj, b_obj_arg typeRef, obj_arg /* w */)
{
	auto val = new GenericValue();
  val->IntVal = int_to_ap(toIntegerType(typeRef)->getBitWidth(), intObj);
	return io_result_mk_ok(mk_generic_value(val));
}

// Create a new integer GenericValue from a Nat and a IntegerType.
extern "C" obj_res papyrus_generic_value_of_nat
(b_obj_arg natObj, b_obj_arg typeRef, obj_arg /* w */)
{
	auto val = new GenericValue();
  val->IntVal = nat_to_ap(toIntegerType(typeRef)->getBitWidth(), natObj);
	return io_result_mk_ok(mk_generic_value(val));
}

// Convert an integer GenericValue to an Int.
extern "C" obj_res papyrus_generic_value_to_int(b_obj_arg valObj, obj_arg /* w */) {
	return io_result_mk_ok(mk_int(toGenericValue(valObj)->IntVal));
}

// Convert an integer GenericValue to a Nat.
extern "C" obj_res papyrus_generic_value_to_nat(b_obj_arg valObj, obj_arg /* w */) {
	return io_result_mk_ok(mk_nat(toGenericValue(valObj)->IntVal));
}

} // end namespace papyrus
