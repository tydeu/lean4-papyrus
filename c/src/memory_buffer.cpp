#include "papyrus.h"

#include <lean/io.h>
#include <llvm/Support/MemoryBuffer.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

static external_object_class* getMemoryBufferClass() {
    // Use static thread to make this thread safe (hopefully).
    static external_object_class* c = registerDeleteClass<MemoryBuffer>();
    return c;
}

MemoryBuffer* toMemoryBuffer(lean::object* bufRef) {
    auto external = lean_to_external(bufRef);
    lean_assert(external->m_calls == getMemoryBufferClass());
    return static_cast<MemoryBuffer*>(external->m_data);
}

extern "C" obj_res papyrus_memory_buffer_from_file(b_obj_arg fnameObj, obj_arg /* w */) {
    auto mbOrErr = MemoryBuffer::getFile(string_to_ref(fnameObj));
    if (std::error_code ec = mbOrErr.getError()) {
      return decode_io_error(ec.value(), fnameObj);
    }
    auto bufPtr = std::move(mbOrErr.get());
    object* bufferObj = lean_alloc_external(getMemoryBufferClass(), bufPtr.get());
    bufPtr.release();
    return io_result_mk_ok(bufferObj);
}

} // end namespace papyrus
