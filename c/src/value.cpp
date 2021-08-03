#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/io.h>
#include <llvm/IR/Value.h>
#include <llvm/ADT/Twine.h>
#include <llvm/Support/raw_ostream.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// Value references
//------------------------------------------------------------------------------

// Wrap an LLVM Value pointer in a Lean object.
obj_res mkValueRef(obj_res ctxRef, llvm::Value* ptr) {
	return mkLinkedLoosePtr<llvm::Value>(ctxRef, ptr);
}

// Get the LLVM Value pointer wrapped in an object.
llvm::Value* toValue(b_obj_arg valueRef) {
	return fromLinkedLoosePtr<llvm::Value>(valueRef);
}

// Get the owning LLVM context object of the given value and increments its RC.
obj_res getValueContext(b_obj_arg valRef) {
  return copyLink(valRef);
}

//------------------------------------------------------------------------------
// Basic functions
//------------------------------------------------------------------------------

// Get a reference to the type of the given value.
extern "C" obj_res papyrus_value_get_type(b_obj_arg valueRef, obj_arg /* w */) {
	return io_result_mk_ok(mkTypeRef(getValueContext(valueRef), toValue(valueRef)->getType()));
}

// Get whether the the given value has a name.
extern "C" obj_res papyrus_value_has_name(b_obj_arg valueRef, obj_arg /* w */) {
  return io_result_mk_ok(lean_box(toValue(valueRef)->hasName()));
}

// Get the name of the given value (or the empty string if none).
extern "C" obj_res papyrus_value_get_name(b_obj_arg valueRef, obj_arg /* w */) {
	return io_result_mk_ok(mkStringFromRef(toValue(valueRef)->getName()));
}

// Set the name of the given value.
// An empty string will remove the value's name.
extern "C" obj_res papyrus_value_set_name
(b_obj_arg strObj, b_obj_arg valueRef, obj_arg /* w */)
{
	toValue(valueRef)->setName(refOfString(strObj));
	return io_result_mk_ok(box(0));
}

// Dump the given value for debugging (to standard error).
extern "C" obj_res papyrus_value_dump(b_obj_arg valueRef, obj_arg /* w */) {
	// simulates Value.dump() since it is not available in release builds
	toValue(valueRef)->print(llvm::errs(), true); llvm::errs() << "\n";
	return io_result_mk_ok(box(0));
}

} // end namespace papyrus
