#include "papyrus.h"

#include <lean/io.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>

using namespace lean;
using namespace llvm;

namespace papyrus {

// JIT Initialization
// ------------------
// The mere presence of these bindings causes
// MCJIT and the Interpreter to be linked in

extern "C" obj_res papyrus_link_in_mcjit(obj_arg /* w */) {
	LLVMLinkInMCJIT();
	return io_result_mk_ok(box(0));
}

extern "C" obj_res papyrus_link_in_interpreter(obj_arg /* w */) {
	LLVMLinkInInterpreter();
	return io_result_mk_ok(box(0));
}

// All Target Initialization

extern "C" obj_res papyrus_init_all_targets(obj_arg /* w */) {
	llvm::InitializeAllTargets();
	return io_result_mk_ok(box(0));
}

extern "C" obj_res papyrus_init_all_target_infos(obj_arg /* w */) {
	llvm::InitializeAllTargetInfos();
	return io_result_mk_ok(box(0));
}

extern "C" obj_res papyrus_init_all_target_mcs(obj_arg /* w */) {
	llvm::InitializeAllTargetMCs();
	return io_result_mk_ok(box(0));
}

extern "C" obj_res papyrus_init_all_asm_parsers(obj_arg /* w */) {
	llvm::InitializeAllAsmParsers();
	return io_result_mk_ok(box(0));
}

extern "C" obj_res papyrus_init_all_asm_printers(obj_arg /* w */) {
	llvm::InitializeAllAsmPrinters();
	return io_result_mk_ok(box(0));
}

extern "C" obj_res papyrus_init_all_disassemblers(obj_arg /* w */) {
	llvm::InitializeAllDisassemblers();
	return io_result_mk_ok(box(0));
}

// Native Target Initialization

extern "C" obj_res papyrus_init_native_target(obj_arg /* w */) {
	return io_result_mk_ok(box(llvm::InitializeNativeTarget()));
}

extern "C" obj_res papyrus_init_native_asm_parser(obj_arg /* w */) {
	return io_result_mk_ok(box(llvm::InitializeNativeTargetAsmParser()));
}

extern "C" obj_res papyrus_init_native_asm_printer(obj_arg /* w */) {
	return io_result_mk_ok(box(llvm::InitializeNativeTargetAsmPrinter()));
}

extern "C" obj_res papyrus_init_native_disassembler(obj_arg /* w */) {
	return io_result_mk_ok(box(llvm::InitializeNativeTargetDisassembler()));
}

} // end namespace papyrus
