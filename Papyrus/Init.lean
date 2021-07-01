namespace Papyrus

-- # All Target Initialization

/-- Initializes all LLVM supported targets. -/
@[extern "papyrus_init_all_targets"]
constant initAllTargets : IO PUnit

/-- Initializes all LLVM supported target MCs. -/
@[extern "papyrus_init_all_target_mcs"]
constant initAllTargetMCs : IO PUnit

/-- Initializes all LLVM supported target infos. -/
@[extern "papyrus_init_all_target_infos"]
constant initAllTargetInfos : IO PUnit

/-- Initializes all LLVM supported target assembly parsers. -/
@[extern "papyrus_init_all_asm_parsers"]
constant initAllAsmParsers : IO PUnit

/-- Initializes all LLVM supported target assembly printers. -/
@[extern "papyrus_init_all_asm_printers"]
constant initAllAsmPrinters : IO PUnit

/-- Initializes all LLVM supported target disassemblers. -/
@[extern "papyrus_init_all_disassemblers"]
constant initAllDisassemblers : IO PUnit

-- # Native Target Initialization

/--
  Initializes the native target along with its MC and Info.
  Returns true if no native target exists, false otherwise.
-/
@[extern "papyrus_init_native_target"]
constant initNativeTarget : IO Bool

/--
  Initializes the native target's ASM parser.
  Returns true if no native target exists, false otherwise.
-/
@[extern "papyrus_init_native_asm_parser"]
constant initNativeAsmParser : IO Bool


/--
  Initializes the native target's ASM printer.
  Returns true if no native target exists, false otherwise.
-/
@[extern "papyrus_init_native_asm_printer"]
constant initNativeAsmPrinter : IO Bool


/--
  Initializes the native target's disassembler.
  Returns true if no native target exists, false otherwise.
-/
@[extern "papyrus_init_native_disassembler"]
constant initNativeDisassembler : IO Bool
