#include "papyrus.h"

#include <lean/io.h>
#include <llvm/IR/GlobalValue.h>
#include <llvm/IR/GlobalObject.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// GLobal Values
//------------------------------------------------------------------------------

// Get the LLVM GlobalValue pointer wrapped in an object.
llvm::GlobalValue* toGlobalValue(lean::object* ref) {
	return llvm::cast<GlobalValue>(toValue(ref));
}

// Get the linkage of a global value.
extern "C" obj_res papyrus_global_value_get_linkage(b_obj_arg gblRef, obj_arg /* w */) {
	return io_result_mk_ok(box(toGlobalValue(gblRef)->getLinkage()));
}

// Set the linkage of a global value.
extern "C" obj_res papyrus_global_value_set_linkage
	(uint8 linkage, b_obj_arg gblRef, obj_arg /* w */)
{
	toGlobalValue(gblRef)->setLinkage(
	  static_cast<GlobalValue::LinkageTypes>(linkage));
	return io_result_mk_ok(box(0));
}

// Get the visibility of a global value.
extern "C" obj_res papyrus_global_value_get_visibility(b_obj_arg gblRef, obj_arg /* w */) {
	return io_result_mk_ok(box(toGlobalValue(gblRef)->getVisibility()));
}

// Set the visibility of a global value.
extern "C" obj_res papyrus_global_value_set_visibility
	(uint8 visibility, b_obj_arg gblRef, obj_arg /* w */)
{
	toGlobalValue(gblRef)->setVisibility(
	  static_cast<GlobalValue::VisibilityTypes>(visibility));
	return io_result_mk_ok(box(0));
}

// Get the DLL storage class of a global value.
extern "C" obj_res papyrus_global_value_get_dll_storage_class(b_obj_arg gblRef, obj_arg /* w */) {
	return io_result_mk_ok(box(toGlobalValue(gblRef)->getDLLStorageClass()));
}

// Set the DLL storage class of a global value.
extern "C" obj_res papyrus_global_value_set_dll_storage_class
	(uint8 dllStorageClass, b_obj_arg gblRef, obj_arg /* w */)
{
	toGlobalValue(gblRef)->setDLLStorageClass(
	  static_cast<GlobalValue::DLLStorageClassTypes>(dllStorageClass));
	return io_result_mk_ok(box(0));
}

// Get the thread local mode of a global value.
extern "C" obj_res papyrus_global_value_get_thread_local_mode
	(b_obj_arg gblRef, obj_arg /* w */)
{
	return io_result_mk_ok(box(toGlobalValue(gblRef)->getThreadLocalMode()));
}

// Set the thread local mode of a global value.
extern "C" obj_res papyrus_global_value_set_thread_local_mode
	(uint8 tlm, b_obj_arg gblRef, obj_arg /* w */)
{
	toGlobalValue(gblRef)->setThreadLocalMode(
	  static_cast<GlobalValue::ThreadLocalMode>(tlm));
	return io_result_mk_ok(box(0));
}

// Get the address significance (unnamed_addr) of a global value.
extern "C" obj_res papyrus_global_value_get_address_significance
	(b_obj_arg gblRef, obj_arg /* w */)
{
	uint8 tag;
	auto kind = toGlobalValue(gblRef)->getUnnamedAddr();
	switch (kind) {
		case GlobalValue::UnnamedAddr::Local:
			tag = 1;
			break;
		case GlobalValue::UnnamedAddr::Global:
			tag = 2;
			break;
		default:
			tag = 0;
			break;
	}
	return io_result_mk_ok(box(tag));
}

// Set the address significance (unnamed_addr) of a global value.
extern "C" obj_res papyrus_global_value_set_address_significance
	(uint8 unnamedAddr, b_obj_arg gblRef, obj_arg /* w */)
{
	GlobalValue::UnnamedAddr kind;
	switch (unnamedAddr) {
		case 1:
			kind = GlobalValue::UnnamedAddr::Local;
			break;
		case 2:
			kind = GlobalValue::UnnamedAddr::Global;
			break;
		default:
			kind = GlobalValue::UnnamedAddr::None;
			break;
	}
	toGlobalValue(gblRef)->setUnnamedAddr(kind);
	return io_result_mk_ok(box(0));
}

// Get the address space of a global value.
extern "C" obj_res papyrus_global_value_get_address_space(b_obj_arg gblRef, obj_arg /* w */) {
	return io_result_mk_ok(box_uint32(toGlobalValue(gblRef)->getAddressSpace()));
}

//------------------------------------------------------------------------------
// GLobal Objects
//------------------------------------------------------------------------------

// Get the LLVM GlobalObject pointer wrapped in an object.
llvm::GlobalObject* toGlobalObject(lean::object* ref) {
	return llvm::cast<GlobalObject>(toValue(ref));
}

// Get whether the global has an explicitly specifiec linker section.
extern "C" obj_res papyrus_global_object_has_section(b_obj_arg gblRef, obj_arg /* w */) {
	return io_result_mk_ok(box(toGlobalObject(gblRef)->hasSection()));
}

// Get the explicit linker section of a global object (or the empty string if none).
extern "C" obj_res papyrus_global_object_get_section(b_obj_arg gblRef, obj_arg /* w */) {
	return io_result_mk_ok(mkStringFromRef(toGlobalObject(gblRef)->getSection()));
}

// Set the explicit linker section of a global object.
// Passing the empty string will remove it.
extern "C" obj_res papyrus_global_object_set_section
	(b_obj_arg strObj, b_obj_arg gblRef, obj_arg /* w */)
{
	toGlobalObject(gblRef)->setSection(refOfString(strObj));
	return io_result_mk_ok(box(0));
}

// Get the explicit power of two alignment of a global object (or 0 if undefined).
extern "C" obj_res papyrus_global_object_get_alignment(b_obj_arg gblRef, obj_arg /* w */) {
	auto align = toGlobalObject(gblRef)->getAlign();
	return io_result_mk_ok(box_uint64(align ? align->value() : 0));
}

// Set the explicit power of two alignment of a global object.
// Passing 0 will remove it.
extern "C" obj_res papyrus_global_object_set_alignment
	(uint64 alignment, b_obj_arg gblRef, obj_arg /* w */)
{
	toGlobalObject(gblRef)->setAlignment(
		alignment == 0 ? MaybeAlign() : MaybeAlign(alignment));
	return io_result_mk_ok(box(0));
}

} // end namespace papyrus
