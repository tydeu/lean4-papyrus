#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/IR/GlobalValue.h>
#include <llvm/IR/GlobalObject.h>

using namespace llvm;

namespace papyrus {

//------------------------------------------------------------------------------
// GLobal Values
//------------------------------------------------------------------------------

// Get the LLVM GlobalValue pointer wrapped in an object.
llvm::GlobalValue* toGlobalValue(lean_object* ref) {
	return llvm::cast<GlobalValue>(toValue(ref));
}

// Get the type of the given global's value.
extern "C" lean_obj_res papyrus_global_value_get_value_type
	(b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	auto type = toGlobalValue(gblRef)->getValueType();
	return lean_io_result_mk_ok(mkTypeRef(copyLink(gblRef), type));
}

// Get the linkage of a global value.
extern "C" lean_obj_res papyrus_global_value_get_linkage(b_lean_obj_res gblRef, lean_obj_arg /* w */) {
	return lean_io_result_mk_ok(lean_box(toGlobalValue(gblRef)->getLinkage()));
}

// Set the linkage of a global value.
extern "C" lean_obj_res papyrus_global_value_set_linkage
	(uint8_t linkage, b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	toGlobalValue(gblRef)->setLinkage(
	  static_cast<GlobalValue::LinkageTypes>(linkage));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the visibility of a global value.
extern "C" lean_obj_res papyrus_global_value_get_visibility(b_lean_obj_res gblRef, lean_obj_arg /* w */) {
	return lean_io_result_mk_ok(lean_box(toGlobalValue(gblRef)->getVisibility()));
}

// Set the visibility of a global value.
extern "C" lean_obj_res papyrus_global_value_set_visibility
	(uint8_t visibility, b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	toGlobalValue(gblRef)->setVisibility(
	  static_cast<GlobalValue::VisibilityTypes>(visibility));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the DLL storage class of a global value.
extern "C" lean_obj_res papyrus_global_value_get_dll_storage_class(b_lean_obj_res gblRef, lean_obj_arg /* w */) {
	return lean_io_result_mk_ok(lean_box(toGlobalValue(gblRef)->getDLLStorageClass()));
}

// Set the DLL storage class of a global value.
extern "C" lean_obj_res papyrus_global_value_set_dll_storage_class
	(uint8_t dllStorageClass, b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	toGlobalValue(gblRef)->setDLLStorageClass(
	  static_cast<GlobalValue::DLLStorageClassTypes>(dllStorageClass));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the thread local mode of a global value.
extern "C" lean_obj_res papyrus_global_value_get_thread_local_mode
	(b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toGlobalValue(gblRef)->getThreadLocalMode()));
}

// Set the thread local mode of a global value.
extern "C" lean_obj_res papyrus_global_value_set_thread_local_mode
	(uint8_t tlm, b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	toGlobalValue(gblRef)->setThreadLocalMode(
	  static_cast<GlobalValue::ThreadLocalMode>(tlm));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the address significance (unnamed_addr) of a global value.
extern "C" lean_obj_res papyrus_global_value_get_address_significance
	(b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	uint8_t tag;
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
	return lean_io_result_mk_ok(lean_box(tag));
}

// Set the address significance (unnamed_addr) of a global value.
extern "C" lean_obj_res papyrus_global_value_set_address_significance
	(uint8_t unnamedAddr, b_lean_obj_res gblRef, lean_obj_arg /* w */)
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
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the address space of a global value.
extern "C" lean_obj_res papyrus_global_value_get_address_space
	(b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box_uint32(toGlobalValue(gblRef)->getAddressSpace()));
}

//------------------------------------------------------------------------------
// GLobal Objects
//------------------------------------------------------------------------------

// Get the LLVM GlobalObject pointer wrapped in an object.
llvm::GlobalObject* toGlobalObject(lean_object* ref) {
	return llvm::cast<GlobalObject>(toValue(ref));
}

// Get whether the global has an explicitly specifiec linker section.
extern "C" lean_obj_res papyrus_global_object_has_section
	(b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(lean_box(toGlobalObject(gblRef)->hasSection()));
}

// Get the explicit linker section of a global object (or the empty string if none).
extern "C" lean_obj_res papyrus_global_object_get_section
	(b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	return lean_io_result_mk_ok(mkStringFromRef(toGlobalObject(gblRef)->getSection()));
}

// Set the explicit linker section of a global object.
// Passing the empty string will remove it.
extern "C" lean_obj_res papyrus_global_object_set_section
	(b_lean_obj_res strObj, b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	toGlobalObject(gblRef)->setSection(refOfString(strObj));
	return lean_io_result_mk_ok(lean_box(0));
}

// Get the explicit power of two alignment of a global object (or 0 if undefined).
extern "C" lean_obj_res papyrus_global_object_get_alignment
	(b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	auto align = toGlobalObject(gblRef)->getAlign();
	return lean_io_result_mk_ok(lean_box_uint64(align ? align->value() : 0));
}

// Set the explicit power of two alignment of a global object.
// Passing 0 will remove it.
extern "C" lean_obj_res papyrus_global_object_set_alignment
	(uint64_t alignment, b_lean_obj_res gblRef, lean_obj_arg /* w */)
{
	toGlobalObject(gblRef)->setAlignment(
		alignment == 0 ? MaybeAlign() : MaybeAlign(alignment));
	return lean_io_result_mk_ok(lean_box(0));
}

} // end namespace papyrus
