import Lean.Parser

namespace Papyrus

namespace Internal
open Lean Parser Command

syntax enumCtor := "\n| " declModifiers ident " := " term

scoped macro (name := enumDecl) mods:declModifiers
"enum" id:ident " : " type:term enums:many(enumCtor) : command => do
  let mut defs : Array Syntax := #[]
  defs := defs.push <| ← `($mods:declModifiers def $id := $type)
  for enum in enums do
    let enumId := enum[2]
    let enumQualId := mkIdentFrom enumId <|
      id.getId.modifyBase (· ++ enumId.getId)
    let enumVal := enum[4]
    let enumMods := enum[1]
    defs := defs.push <| ←
      `($enumMods:declModifiers def $enumQualId:ident : $id := ($enumVal : $type))
  mkNullNode defs

end Internal
open Internal

/--
  LLVM calling conventions.
  Note that LLVM IR allows arbitrary numbers as calling convention identifiers.
-/
enum CallingConvention : UInt32
| /--
    The default llvm calling convention, compatible with C.

    This convention is the only calling convention that supports `vararg` calls.
    As with typical C calling conventions, the callee/caller have to tolerate
    certain amounts of prototype mismatch.
  -/
  c := 0
| /--
    This calling convention attempts to make calls as fast as possible
    (e.g., by passing things in registers).
  -/
  fast := 8
| /--
    This calling convention attempts to make code in the caller as
    efficient as possible under the assumption that the call is not commonly
    executed.
    As such, these calls often preserve all registers so that the call does not
    break any live ranges in the caller side.
  -/
  cold := 9
| /-- Calling convention used by the Glasgow Haskell Compiler (GHC) -/
  ghc := 10
| /-- Calling convention used by the High-Performance Erlang Compiler (HiPE).-/
  hipe := 11
| /-- Calling convention for stack based JavaScript calls. -/
  webKitJS := 12
| /--
    Calling convention for dynamic register based calls
    (e.g., `stackmap` and `patchpoint` intrinsics).
  -/
  anyReg := 13
| /-- Calling convention for runtime calls that preserves most registers. -/
  preserveMost := 14
| /-- Calling convention for runtime calls that preserves (almost) all registers. -/
  preserveAll := 15
| /-- Calling convention for Swift. -/
  swift := 16
| /-- Calling convention for access functions. -/
  cxxFastTLS := 17
| /--
    This calling convention attempts to make calls as fast as possible
    while guaranteeing that tail call optimization can always be performed.
  -/
  tail := 18
| /--
    Calling convention on Windows for the Control Guard Check ICall function.
    The function takes exactly one argument (the address of the target function)
    passed in the first argument register, and has no return value.
    All register values are preserved.
  -/
  cfGuardCheck := 19
| /--
    This follows the Swift calling convention in how arguments are passed but
    guarantees tail calls will be made by making the callee clean up their stack.
  -/
  swiftTail := 20
| /--
    `stdcall` is the calling conventions mostly used by the Win32 API.
    It is basically the same as the C convention with the difference in that
    the callee is responsible for popping the arguments from the stack.
  -/
  x86StdCall := 64
| /--
    `fast` analog of `x86StdCall`.
    Passes first two arguments in `ECX`:`EDX` registers, others - via stack.
    Callee is responsible for stack cleaning.
  -/
  x86FastCall := 65
| /--
    ARM Procedure Calling Standard calling convention
    (obsolete, but still used on some targets).
  -/
  armAPCS := 55
| /--
    ARM Architecture Procedure Calling Standard calling convention (aka EABI).
    Soft floating point ABI.
  -/
  armAAPCS := 67
| /--
    ARM Architecture Procedure Calling Standard calling convention (aka EABI).
    Hard floating point ABI.
  -/
  armAAPCSVFP := 68
| /-- Calling convention used for MSP430 interrupt routines. -/
  msp430Intr := 69
| /--
    Similar to `x86StdCall`.
    Passes first argument in ECX, others via stack.
    Callee is responsible for stack cleaning.
    MSVC uses this by default for methods in its ABI.
  -/
  x86ThisCall := 70
| /-- Call to a PTX kernel. Passes all arguments in parameter space. -/
  ptxKernel := 71
| /--
    Call to a PTX device function.
    Passes all arguments in register or parameter space.
  -/
  ptxDevice := 72
| /--
    Calling convention for SPIR non-kernel device functions.

    * No lowering or expansion of arguments.
    * Structures are passed as a pointer to a struct with the `byval` attribute.
    * Functions can only call `spirFunc` and `spirKernel` functions.
    * Functions can only have zero or one return values.
    * Variable arguments are not allowed, except for `printf`.
    * How arguments/return values are lowered are not specified.
    * Functions are only visible to the devices.
  -/
  spirFunc := 75
| /--
    Calling convention for SPIR kernel functions.

    Inherits the restrictions of `spirFunc`, except:
    * Cannot have non-void return values.
    * Cannot have variable arguments.
    * Can also be called by the host.
    * Is externally visible.
  -/
  spirKernel := 76
| /-- Calling conventions for Intel OpenCL built-ins. -/
  intelOCLBuiltin := 77
| /--
    The C convention as specified in the x86-64 supplement to the System V ABI,
    used on most non-Windows systems.
  -/
  x8664SysV := 78
| /--
    The C convention as implemented on Windows/x86-64 and AArch64.

    This convention differs from the more common `x8664SysV` convention in a
    number of ways, most notably in that XMM registers used to pass arguments are
    shadowed by GPRs, and vice versa.

    On AArch64, this is identical to the normal C (AAPCS) calling
    convention for normal functions, but floats are passed in integer
    registers to variadic functions.
  -/
  win64 := 79
| /-- MSVC calling convention that passes vectors and vector aggregates in SSE registers. -/
  x86VectorCall := 80
| /--
    Calling convention used by HipHop Virtual Machine (HHVM) to
    perform calls to and from translation cache and for calling PHP functions.

    The HHVM calling convention supports tail/sibling call elimination.
  -/
  hhvm := 81
| /-- HHVM calling convention for invoking C/C++ helpers. -/
  hhvmC := 82
| /--
    x86 hardware interrupt context.
    Callee may take one or two parameters, where the 1st represents a pointer
    to hardware context frame and the 2nd represents hardware error code,
    the presence of the later depends on the interrupt vector taken.
    Valid for both 32- and 64-bit subtargets.
  -/
  x86Intr := 83
| /-- Calling convention used for AVR interrupt routines. -/
  avrIntr := 84
| /-- Calling convention used for AVR signal routines. -/
  avrSignal := 85
| /--
    Calling convention used for special AVR rtlib functions which have an
    "optimized" convention to preserve registers.
  -/
  avrBuiltin := 86
| /--
    Calling convention used for Mesa vertex shaders, or AMDPAL last shader
    stage before rasterization (vertex shader if tessellation and geometry
    are not in use, or otherwise copy shader if one is needed).
  -/
  amdGpuVS := 87
| /-- Calling convention used for Mesa/AMDPAL geometry shaders. -/
  amdGpuGS := 88
| /-- Calling convention used for Mesa/AMDPAL pixel shaders. -/
  amdGpuPS := 89
| /--  Calling convention used for Mesa/AMDPAL compute shaders. -/
  amdGpuCS := 90
| /-- Calling convention for AMDGPU code object kernels. -/
  amdGpuKernel := 91
| /-- Register calling convention used for parameters transfer optimization. -/
  x86RegCall := 92
| /--
    Calling convention used for Mesa/AMDPAL hull shaders
    (= tessellation control shaders).
  -/
  amdGpuHs := 93
| /--
     Calling convention used for special MSP430 rtlib functions
     which have an "optimized" convention using additional registers.
  -/
  msp430Builtin := 94
| /-- Calling convention used for AMDPAL vertex shader if tessellation is in use. -/
  amdGpuLs := 95
| /--
    Calling convention used for AMDPAL shader stage before geometry shader
    if geometry is in use. So either the domain (= tessellation evaluation)
    shader if tessellation is in use, or otherwise the vertex shader.
  -/
  amdGpuES := 96
| /-- Calling convention between AArch64 Advanced SIMD functions -/
  aarch64VectorCall := 97
| /-- Calling convention between AArch64 SVE functions. -/
  aarch64SVEVectorCall := 98
| /--
    Calling convention for `emscripten __invoke_*` functions. The first
    argument is required to be the function ptr being indirectly called.
    The remainder matches the regular calling convention.
  -/
  wasmEmscriptenInvoke := 99
| /-- Calling convention used for AMD graphics targets. -/
  amdGpuGfx := 100
| /-- Calling convention used for M68k interrupt routines. -/
  m68kIntr := 101

namespace CallingConvention

/-- The default calling convention (i.e., `c`). -/
def default : CallingConvention := c

/--
  This is the start of the target-specific calling conventions
  (e.g., `x86FastCall`).
-/
def firstTargetID : CallingConvention := (63 : UInt32)

/-- The highest possible calling convention ID. -/
def maxID : CallingConvention := (1023 : UInt32)

end CallingConvention

instance : BEq CallingConvention := inferInstanceAs (BEq UInt32)
instance : DecidableEq CallingConvention := inferInstanceAs (DecidableEq UInt32)
instance : Repr CallingConvention := inferInstanceAs (Repr UInt32)
instance : Inhabited CallingConvention := ⟨CallingConvention.default⟩
