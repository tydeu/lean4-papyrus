#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/IR/Value.h>
#include <llvm/ADT/Twine.h>
#include <llvm/Support/raw_ostream.h>

using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// Value references
//------------------------------------------------------------------------------

// Wrap an LLVM Value pointer in a Lean object.
lean_obj_res mkValueRef(lean_obj_arg ctxRef, llvm::Value* ptr) {
	return mkLinkedLoosePtr<llvm::Value>(ctxRef, ptr);
}

// Get the LLVM Value pointer wrapped in an object.
llvm::Value* toValue(b_lean_obj_res valueRef) {
	return fromLinkedLoosePtr<llvm::Value>(valueRef);
}

// Get the owning LLVM context object of the given value and increments its RC.
lean_obj_res getValueContext(b_lean_obj_res valRef) {
  return copyLink(valRef);
}

//------------------------------------------------------------------------------
// Basic functions
//------------------------------------------------------------------------------

// Get the ID of the given value.
// As a value's ID is immutable, we don't need to wrap it in IO.
extern "C" uint32_t papyrus_value_id(b_lean_obj_res valueRef) {
	return toValue(valueRef)->getValueID();
}

// Get a reference to the type of the given value.
extern "C" lean_obj_res papyrus_value_get_type
	(b_lean_obj_res valueRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(mkTypeRef(getValueContext(valueRef), toValue(valueRef)->getType()));
}

// Get whether the the given value has a name.
extern "C" lean_obj_res papyrus_value_has_name
	(b_lean_obj_res valueRef, lean_obj_arg /* w */)
{
  return lean_io_result_mk_ok(lean_box(toValue(valueRef)->hasName()));
}

// Get the name of the given value (or the empty string if none).
extern "C" lean_obj_res papyrus_value_get_name
	(b_lean_obj_res valueRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(mkStringFromRef(toValue(valueRef)->getName()));
}

// Set the name of the given value.
// An empty string will remove the value's name.
extern "C" lean_obj_res papyrus_value_set_name
(b_lean_obj_res strObj, b_lean_obj_res valueRef, lean_obj_arg /* w */)
{
	toValue(valueRef)->setName(refOfString(strObj));
	return lean_io_result_mk_ok(lean_box(0));
}

// Print the given value to LLVM's standard output.
extern "C" lean_obj_res papyrus_value_print
	(b_lean_obj_res valueRef, uint8_t isForDebug, lean_obj_arg /* w */)
{
	toValue(valueRef)->print(llvm::outs(), isForDebug);
	return lean_io_result_mk_ok(lean_box(0));
}

// Print the given value to LLVM's standard error.
extern "C" lean_obj_res papyrus_value_eprint
	(b_lean_obj_res valueRef, uint8_t isForDebug, lean_obj_arg /* w */)
{
	toValue(valueRef)->print(llvm::errs(), isForDebug);
	return lean_io_result_mk_ok(lean_box(0));
}

// Print the given value to a string.
extern "C" lean_obj_res papyrus_value_sprint
	(b_lean_obj_res valueRef, uint8_t isForDebug, lean_obj_arg /* w */)
{
	std::string ostr;
	raw_string_ostream out(ostr);
	toValue(valueRef)->print(out, isForDebug);
	return lean_io_result_mk_ok(mkStringFromStd(out.str()));
}

} // end namespace papyrus
