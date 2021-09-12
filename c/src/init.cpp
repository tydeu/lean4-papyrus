#include "papyrus.h"

#include <lean/lean.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>

using namespace llvm;

namespace papyrus {

// JIT Initialization
// ------------------
// The mere presence of these bindings causes
// MCJIT and the Interpreter to be linked in

extern "C" lean_obj_res papyrus_link_in_mcjit(lean_obj_arg /* w */) {
	LLVMLinkInMCJIT();
	return lean_io_result_mk_ok(lean_box(0));
}

extern "C" lean_obj_res papyrus_link_in_interpreter(lean_obj_arg /* w */) {
	LLVMLinkInInterpreter();
	return lean_io_result_mk_ok(lean_box(0));
}

// All Target Initialization

extern "C" lean_obj_res papyrus_init_all_targets(lean_obj_arg /* w */) {
	llvm::InitializeAllTargets();
	return lean_io_result_mk_ok(lean_box(0));
}

extern "C" lean_obj_res papyrus_init_all_target_infos(lean_obj_arg /* w */) {
	llvm::InitializeAllTargetInfos();
	return lean_io_result_mk_ok(lean_box(0));
}

extern "C" lean_obj_res papyrus_init_all_target_mcs(lean_obj_arg /* w */) {
	llvm::InitializeAllTargetMCs();
	return lean_io_result_mk_ok(lean_box(0));
}

extern "C" lean_obj_res papyrus_init_all_asm_parsers(lean_obj_arg /* w */) {
	llvm::InitializeAllAsmParsers();
	return lean_io_result_mk_ok(lean_box(0));
}

extern "C" lean_obj_res papyrus_init_all_asm_printers(lean_obj_arg /* w */) {
	llvm::InitializeAllAsmPrinters();
	return lean_io_result_mk_ok(lean_box(0));
}

extern "C" lean_obj_res papyrus_init_all_disassemblers(lean_obj_arg /* w */) {
	llvm::InitializeAllDisassemblers();
	return lean_io_result_mk_ok(lean_box(0));
}

// Native Target Initialization

extern "C" lean_obj_res papyrus_init_native_target(lean_obj_arg /* w */) {
	return lean_io_result_mk_ok(lean_box(llvm::InitializeNativeTarget()));
}

extern "C" lean_obj_res papyrus_init_native_asm_parser(lean_obj_arg /* w */) {
	return lean_io_result_mk_ok(lean_box(llvm::InitializeNativeTargetAsmParser()));
}

extern "C" lean_obj_res papyrus_init_native_asm_printer(lean_obj_arg /* w */) {
	return lean_io_result_mk_ok(lean_box(llvm::InitializeNativeTargetAsmPrinter()));
}

extern "C" lean_obj_res papyrus_init_native_disassembler(lean_obj_arg /* w */) {
	return lean_io_result_mk_ok(lean_box(llvm::InitializeNativeTargetDisassembler()));
}

} // end namespace papyrus
