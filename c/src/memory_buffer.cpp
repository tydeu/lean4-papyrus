#include "papyrus.h"
#include "papyrus_ffi.h"

#include <lean/io.h>
#include <llvm/Support/MemoryBuffer.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

lean::object* mkMemoryBufferRef(MemoryBuffer* ptr) {
	return mkOwnedPtr<MemoryBuffer>(ptr);
}

MemoryBuffer* toMemoryBuffer(lean::object* ref) {
	return fromOwnedPtr<MemoryBuffer>(ref);
}

extern "C" obj_res papyrus_memory_buffer_from_file(b_obj_arg fnameObj, obj_arg /* w */) {
	auto mbOrErr = MemoryBuffer::getFile(refOfString(fnameObj));
	if (std::error_code ec = mbOrErr.getError()) {
	  return decode_io_error(ec.value(), fnameObj);
	}
	auto bufPtr = std::move(mbOrErr.get());
	object* bufObj = mkMemoryBufferRef(bufPtr.get());
	bufPtr.release();
	return io_result_mk_ok(bufObj);
}

} // end namespace papyrus
