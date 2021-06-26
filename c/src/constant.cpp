#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/Constants.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// Generic constants
//------------------------------------------------------------------------------

// Get the null constant of the given type object.
extern "C" obj_res papyrus_get_null_constant(b_obj_arg typeObj, obj_arg /* w */) {
    auto constant = Constant::getNullValue(toType(typeObj));
    return io_result_mk_ok(mk_value_ref(getTypeContext(typeObj), constant));
}

// Get the all ones constant of the given type object.
extern "C" obj_res papyrus_get_all_ones_constant(b_obj_arg typeObj, obj_arg /* w */) {
    auto constant = Constant::getAllOnesValue(toType(typeObj));
    return io_result_mk_ok(mk_value_ref(getTypeContext(typeObj), constant));
}

//------------------------------------------------------------------------------
// Constant integers
//------------------------------------------------------------------------------

// Get the LLVM ConstantInt pointer wrapped in an object.
llvm::ConstantInt* toConstantInt(lean::object* constObj) {
    return llvm::cast<ConstantInt>(toValue(constObj));
}

// Get a reference to a constant of the given Int value,
// truncating and/or extending it as necessary to fit in the given type.
extern "C" obj_res papyrus_get_constant_int
(b_obj_arg intObj, b_obj_arg typeObj, obj_arg /* w */)
{
    auto ctxObj = getTypeContext(typeObj);
    auto numBits = llvm::cast<IntegerType>(toType(typeObj))->getBitWidth();
    auto cnst = ConstantInt::get(*toLLVMContext(ctxObj), int_to_ap(numBits, intObj));
    return io_result_mk_ok(mk_value_ref(ctxObj, cnst));
}

// Get the Int value of the given integer constant object.
extern "C" obj_res papyrus_constant_int_get_value(b_obj_arg constObj, obj_arg /* w */) {
    return io_result_mk_ok(mk_int(toConstantInt(constObj)->getValue()));
}

// Get the Nat value of the given integer constant object.
extern "C" obj_res papyrus_constant_int_get_nat_value(b_obj_arg constObj, obj_arg /* w */) {
    return io_result_mk_ok(mk_nat(toConstantInt(constObj)->getValue()));
}

} // end namespace papyrus
