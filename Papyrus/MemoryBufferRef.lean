namespace Papyrus

/--
  A reference to the LLVM representation of a
  [MemoryBuffer](https://llvm.org/doxygen/classllvm_1_1MemoryBuffer.html).
-/
constant MemoryBufferRef : Type := Unit

/-- Construct a memory buffer from a file. -/
@[extern "papyrus_memory_buffer_from_file"]
constant MemoryBufferRef.fromFile (file : @& System.FilePath) : IO MemoryBufferRef
