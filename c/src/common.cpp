#include "papyrus.h"

#include <lean/utf8.h>
#include <llvm/ADT/StringRef.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

void nopForeach(void*, b_obj_arg) {
  return;
}

lean::object* mk_string(const llvm::StringRef& str) {
    size_t size  = str.size();
    size_t len = lean::utf8_strlen(str.data(), size);
    size_t realSize = size + 1;
    lean::object* obj = alloc_string(realSize, realSize, len);
    auto data = lean_to_string(obj)->m_data;
    memcpy(data, str.data(), size);
    data[size] = 0;
    return obj;
}

const llvm::StringRef string_to_ref(lean::object* obj) {
  lean_assert(is_string(obj));
  return llvm::StringRef(lean_to_string(obj)->m_data, string_size(obj) - 1);
}

} // end namespace papyrus
