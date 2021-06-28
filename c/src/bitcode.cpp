#include "papyrus.h"

#include <lean/io.h>
#include <llvm/Bitcode/BitcodeReader.h>
#include <llvm/Bitcode/BitcodeWriter.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

extern "C" obj_res papyrus_module_write_bitcode_to_file
(b_obj_arg fnameObj, b_obj_arg modObj, uint8 perserveOrder, obj_arg /* w */)
{
    std::error_code ec;
    raw_fd_ostream out(string_to_ref(fnameObj), ec);
    if (ec) return decode_io_error(ec.value(), fnameObj);
    llvm::WriteBitcodeToFile(*toModule(modObj), out, perserveOrder);
    return io_result_mk_ok(box(0));
}

extern "C" obj_res papyrus_module_parse_bitcode_from_buffer
(b_obj_arg bufObj, obj_arg ctxObj, obj_arg /* w */)
{
    auto ctx = toLLVMContext(ctxObj);
    MemoryBufferRef buf = toMemoryBuffer(bufObj)->getMemBufferRef();
    auto moduleOrErr = llvm::parseBitcodeFile(buf, *ctx);
    if (!moduleOrErr) {
        dec_ref(ctxObj);
        std::string errMsg = "failed to parse bitcode file";
        handleAllErrors(std::move(moduleOrErr.takeError()), [&](llvm::ErrorInfoBase &eib) {
            errMsg = "failed to parse bitcode file:" + eib.message();
        });
        return io_result_mk_error( errMsg.c_str() );
    }
    return io_result_mk_ok(mk_module_ref(ctxObj, std::move(*moduleOrErr)));
}

} // end namespace lean_llvm
