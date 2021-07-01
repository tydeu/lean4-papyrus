import Papyrus.FFI

namespace Papyrus

/--
  An opaque type representing an LLVM
  [MemoryBuffer](https://llvm.org/doxygen/classllvm_1_1MemoryBuffer.html).
-/
constant LLVM.MemoryBuffer : Type := Unit

/--
  A reference to an external LLVM
  [MemoryBuffer](https://llvm.org/doxygen/classllvm_1_1MemoryBuffer.html).
-/
def MemoryBufferRef := OwnedPtr LLVM.MemoryBuffer

/-- Construct a memory buffer from a file. -/
@[extern "papyrus_memory_buffer_from_file"]
constant MemoryBufferRef.fromFile (file : @& System.FilePath) : IO MemoryBufferRef
