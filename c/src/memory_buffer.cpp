#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/lean.h>
#include <llvm/Support/MemoryBuffer.h>

using namespace llvm;

namespace papyrus {

lean_object* mkMemoryBufferRef(MemoryBuffer* ptr) {
	return mkOwnedPtr<MemoryBuffer>(ptr);
}

MemoryBuffer* toMemoryBuffer(lean_object* ref) {
	return fromOwnedPtr<MemoryBuffer>(ref);
}

extern "C" lean_obj_res papyrus_memory_buffer_from_file(b_lean_obj_res fnameObj, lean_obj_arg /* w */) {
	auto mbOrErr = MemoryBuffer::getFile(refOfString(fnameObj));
	if (std::error_code ec = mbOrErr.getError()) {
	  return lean_decode_io_error(ec.value(), fnameObj);
	}
	auto bufPtr = std::move(mbOrErr.get());
	lean_object* bufObj = mkMemoryBufferRef(bufPtr.get());
	bufPtr.release();
	return lean_io_result_mk_ok(bufObj);
}

} // end namespace papyrus
