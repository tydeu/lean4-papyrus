#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Constants.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// Generic constants
//------------------------------------------------------------------------------

// Get the null constant of the given type.
extern "C" obj_res papyrus_get_null_constant(b_obj_arg typeRef, obj_arg /* w */) {
	auto constant = Constant::getNullValue(toType(typeRef));
	return io_result_mk_ok(mk_value_ref(getTypeContext(typeRef), constant));
}

// Get the all ones constant of the given type.
extern "C" obj_res papyrus_get_all_ones_constant(b_obj_arg typeRef, obj_arg /* w */) {
	auto constant = Constant::getAllOnesValue(toType(typeRef));
	return io_result_mk_ok(mk_value_ref(getTypeContext(typeRef), constant));
}

//------------------------------------------------------------------------------
// Constant words / integers / naturals
//------------------------------------------------------------------------------

// Get the LLVM ConstantInt pointer wrapped in an object.
llvm::ConstantInt* toConstantInt(lean::object* constRef) {
	return llvm::cast<ConstantInt>(toValue(constRef));
}

// Get a reference to a constant of the given Int value,
// truncating and/or extending it as necessary to fit in the given type.
extern "C" obj_res papyrus_get_constant_int
(b_obj_arg intObj, b_obj_arg typeRef, obj_arg /* w */)
{
	auto ctxObj = getTypeContext(typeRef);
	auto numBits = toIntegerType(typeRef)->getBitWidth();
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), int_to_ap(numBits, intObj));
	return io_result_mk_ok(mk_value_ref(ctxObj, n));
}

// Get a reference to a constant of the given Nat value,
// truncating and/or extending it as necessary to fit in the given type.
extern "C" obj_res papyrus_get_constant_nat
(b_obj_arg intObj, b_obj_arg typeRef, obj_arg /* w */)
{
	auto ctxObj = getTypeContext(typeRef);
	auto numBits = toIntegerType(typeRef)->getBitWidth();
	auto n = ConstantInt::get(*toLLVMContext(ctxObj), nat_to_ap(numBits, intObj));
	return io_result_mk_ok(mk_value_ref(ctxObj, n));
}

// Get the Int value of the given integer constant.
extern "C" obj_res papyrus_constant_word_get_int_value(b_obj_arg constRef, obj_arg /* w */) {
	return io_result_mk_ok(mk_int(toConstantInt(constRef)->getValue()));
}

// Get the Nat value of the given integer constant.
extern "C" obj_res papyrus_constant_word_get_nat_value(b_obj_arg constRef, obj_arg /* w */) {
	return io_result_mk_ok(mk_nat(toConstantInt(constRef)->getValue()));
}

} // end namespace papyrus
