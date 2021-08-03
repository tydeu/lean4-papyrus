#pragma once
#include <lean/object.h>

namespace papyrus {

//------------------------------------------------------------------------------
// External object callbacks
//------------------------------------------------------------------------------

// A no-op finalize callback for external classes.
static void nopFinalize(void* p) {
  return;
}

// A finalize callback for external classes that
// casts the pointer to the template type and then invokes delete.
template<typename T>
void deleteFinalize(void* p) {
	delete static_cast<T*>(p);
}

// A no-op foreach callback for external classes.
static void nopForeach(void* /* p */, b_lean_obj_arg /* a */) {
  return;
}

//------------------------------------------------------------------------------
// Unmanaged (Loose) Pointers
//------------------------------------------------------------------------------

// Lean external object class for unmanaged pointers.
template<typename T> static lean_external_class* getLoosePtrClass() {
	// Use static to make this thread safe by static initialization rules.
	static lean_external_class* k =
    lean_register_external_class(&nopFinalize, &nopForeach);
	return k;
}

// Wrap a unmanaged pointer in a Lean object.
template<typename T> lean_object* mkLoosePtr(T* ptr) {
	return lean_alloc_external(getLoosePtrClass<T>(), ptr);
}

// Get the pointer wrapped in an LoosePtr.
template<typename T> T* fromLoosePtr(b_lean_obj_arg ctxRef) {
	lean_external_object* external = lean_to_external(ctxRef);
	assert(external->m_class == getLoosePtrClass<T>());
	return static_cast<T*>(external->m_data);
}

//------------------------------------------------------------------------------
// Lean-Owned Pointers
//------------------------------------------------------------------------------

// Lean external object class template for Lean owned pointers.
template<typename T> static lean_external_class* getOwnedPtrClass() {
	// Use static to make this thread safe by static initialization rules.
	static lean_external_class* k =
    lean_register_external_class(&deleteFinalize<T>, &nopForeach);
	return k;
}

// Wrap an pointer in a Lean object, transfering ownership to it.
template<typename T> lean_obj_res mkOwnedPtr(T* ptr) {
	return lean_alloc_external(getOwnedPtrClass<T>(), ptr);
}

// Get the Lean-owned pointer wrapped in an OwnedPtr.
template<typename T> T* fromOwnedPtr(b_lean_obj_arg obj) {
	lean_external_object* external = lean_to_external(obj);
	assert(external->m_class == getOwnedPtrClass<T>());
	return static_cast<T*>(external->m_data);
}

//------------------------------------------------------------------------------
// Linked Pointers
//------------------------------------------------------------------------------

// Borrow the object linked to the a linked pointer object.
static inline b_lean_obj_res borrowLink(b_lean_obj_arg linkedPtrObj) {
	return lean_ctor_get(linkedPtrObj, 0);
}

// Get the object linked to the a linked pointer object and increment its RC.
static inline lean_obj_res copyLink(b_lean_obj_arg linkedPtrObj) {
	auto link = lean_ctor_get(linkedPtrObj, 0);
	lean_inc_ref(link);
	return link;
}

// Wrap a pointer in a linked pointer object, transfering ownership to of it to Lean.
template<typename T> lean_obj_res mkLinkedOwnedPtr(b_lean_obj_arg link, T* ptr) {
	lean_object* obj = lean_alloc_ctor(0, 2, 0);
	lean_ctor_set(obj, 0, link);
	lean_ctor_set(obj, 1, mkOwnedPtr<T>(ptr));
	return obj;
}

// Get the Lean-owned pointer wrapped in an object.
template<typename T> T* fromLinkedOwnedPtr(b_lean_obj_arg obj) {
	return fromOwnedPtr<T>(lean_ctor_get(obj, 1));
}

// Wrap a loose pointer in a Lean LinkedPtr.
template<typename T> lean_obj_res mkLinkedLoosePtr(b_lean_obj_arg link, T* ptr) {
	lean_object* obj = lean_alloc_ctor(0, 2, 0);
	lean_ctor_set(obj, 0, link);
	lean_ctor_set(obj, 1, mkLoosePtr<T>(ptr));
	return obj;
}

// Get the loose pointer wrapped in linked pointer object.
template<typename T> T* fromLinkedLoosePtr(b_lean_obj_arg obj) {
	return fromLoosePtr<T>(lean_ctor_get(obj, 1));
}

} // end namespace papyrus
