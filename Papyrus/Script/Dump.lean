import Papyrus.IR.Types
import Papyrus.IR.TypeRefs
import Papyrus.IR.ConstantRefs
import Papyrus.IR.InstructionRefs
import Papyrus.IR.ModuleRef
import Papyrus.Script.SyntaxUtil

namespace Papyrus.Script

-- # Dump Class

class DumpRef (α : Type u) where
  dumpRef : α → IO PUnit

export DumpRef (dumpRef)

class Dump (α : Type u) where
  dump : α → LlvmM PUnit

export Dump (dump)

instance [DumpRef α] : Dump α := ⟨liftM ∘ dumpRef⟩

instance : DumpRef TypeRef := ⟨(·.dump)⟩
instance : DumpRef VoidTypeRef := ⟨(·.dump)⟩
instance : DumpRef LabelTypeRef := ⟨(·.dump)⟩
instance : DumpRef MetadataTypeRef := ⟨(·.dump)⟩
instance : DumpRef TokenTypeRef := ⟨(·.dump)⟩
instance : DumpRef X86MMXTypeRef := ⟨(·.dump)⟩
instance : DumpRef X86AMXTypeRef := ⟨(·.dump)⟩
instance : DumpRef HalfTypeRef := ⟨(·.dump)⟩
instance : DumpRef BFloatTypeRef := ⟨(·.dump)⟩
instance : DumpRef FloatTypeRef := ⟨(·.dump)⟩
instance : DumpRef DoubleTypeRef := ⟨(·.dump)⟩
instance : DumpRef X86FP80TypeRef := ⟨(·.dump)⟩
instance : DumpRef FP128TypeRef := ⟨(·.dump)⟩
instance : DumpRef PPCFP128TypeRef := ⟨(·.dump)⟩
instance : DumpRef IntegerTypeRef := ⟨(·.dump)⟩
instance : DumpRef FunctionTypeRef := ⟨(·.dump)⟩
instance : DumpRef PointerTypeRef := ⟨(·.dump)⟩
instance : DumpRef StructTypeRef := ⟨(·.dump)⟩
instance : DumpRef LiteralStructTypeRef := ⟨(·.dump)⟩
instance : DumpRef IdentifiedStructTypeRef := ⟨(·.dump)⟩
instance : DumpRef ArrayTypeRef := ⟨(·.dump)⟩
instance : DumpRef VectorTypeRef := ⟨(·.dump)⟩
instance : DumpRef FixedVectorTypeRef := ⟨(·.dump)⟩
instance : DumpRef ScalableVectorTypeRef := ⟨(·.dump)⟩

instance : Dump «Type» := ⟨fun t => do dump <| ← t.getRef⟩
instance : Dump IntegerType := ⟨fun t => do dump <| ← t.getRef⟩
instance : Dump FunctionType := ⟨fun t => do dump <| ← t.getRef⟩
instance : Dump PointerType := ⟨fun t => do dump <| ← t.getRef⟩
instance : Dump StructType := ⟨fun t => do dump <| ← t.getRef⟩
instance : Dump ArrayType := ⟨fun t => do dump <| ← t.getRef⟩
instance : Dump VectorType := ⟨fun t => do dump <| ← t.getRef⟩
instance : Dump FixedVectorType := ⟨fun t => do dump <| ← t.getRef⟩
instance : Dump ScalableVectorType := ⟨fun t => do dump <| ← t.getRef⟩

instance : DumpRef ValueRef := ⟨(·.dump)⟩
instance : DumpRef UserRef := ⟨(·.dump)⟩
instance : DumpRef ConstantRef := ⟨(·.dump)⟩
instance : DumpRef ConstantIntRef := ⟨(·.dump)⟩
instance : DumpRef ConstantDataArrayRef := ⟨(·.dump)⟩
instance : DumpRef FunctionRef := ⟨(·.dump)⟩
instance : DumpRef GlobalValueRef := ⟨(·.dump)⟩
instance : DumpRef GlobalObjectRef := ⟨(·.dump)⟩
instance : DumpRef GlobalVariableRef := ⟨(·.dump)⟩

instance : DumpRef InstructionRef := ⟨(·.dump)⟩
instance : DumpRef ReturnInstRef := ⟨(·.dump)⟩

instance : DumpRef ModuleRef := ⟨ModuleRef.dump⟩

-- # Dump Command

macro kw:"#dump " x:term : command => do
  mkEvalAt kw <| ← ``(LlvmM.run ($x >>= dump))
