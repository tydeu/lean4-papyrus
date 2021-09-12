#include "papyrus.h"

#include <lean/lean.h>
#include <llvm/Bitcode/BitcodeReader.h>
#include <llvm/Bitcode/BitcodeWriter.h>

using namespace llvm;

namespace papyrus {

extern "C" lean_obj_res papyrus_module_write_bitcode_to_file
	(b_lean_obj_res fnameObj, b_lean_obj_res modObj, uint8_t perserveOrder,
		lean_obj_arg /* w */)
{
	std::error_code ec;
	raw_fd_ostream out(refOfString(fnameObj), ec);
	if (ec) return lean_decode_io_error(ec.value(), fnameObj);
	llvm::WriteBitcodeToFile(*toModule(modObj), out, perserveOrder);
	return lean_io_result_mk_ok(lean_box(0));
}

extern "C" lean_obj_res papyrus_module_parse_bitcode_from_buffer
(b_lean_obj_res bufObj, lean_obj_arg ctxObj, lean_obj_arg /* w */)
{
	auto ctx = toLLVMContext(ctxObj);
	MemoryBufferRef buf = toMemoryBuffer(bufObj)->getMemBufferRef();
	Expected<std::unique_ptr<Module>> moduleOrErr = llvm::parseBitcodeFile(buf, *ctx);
	if (!moduleOrErr) {
		lean_dec_ref(ctxObj);
		std::string errMsg = "failed to parse bitcode file";
		handleAllErrors(std::move(moduleOrErr.takeError()), [&](llvm::ErrorInfoBase &eib) {
			errMsg = "failed to parse bitcode file:" + eib.message();
		});
		return mkStdStringError(errMsg);
	}
	return lean_io_result_mk_ok(mkModuleRef(ctxObj, moduleOrErr.get().release()));
}

} // end namespace lean_llvm
