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

instance : DumpRef TypeRef := ⟨TypeRef.dump⟩
instance : DumpRef IntegerTypeRef := ⟨TypeRef.dump⟩
instance : DumpRef FunctionTypeRef := ⟨TypeRef.dump⟩
instance : DumpRef PointerTypeRef := ⟨TypeRef.dump⟩
instance : DumpRef StructTypeRef := ⟨TypeRef.dump⟩
instance : DumpRef LiteralStructTypeRef := ⟨TypeRef.dump⟩
instance : DumpRef IdentifiedStructTypeRef := ⟨TypeRef.dump⟩
instance : DumpRef ArrayTypeRef := ⟨TypeRef.dump⟩
instance : DumpRef VectorTypeRef := ⟨TypeRef.dump⟩
instance : DumpRef FixedVectorTypeRef := ⟨TypeRef.dump⟩
instance : DumpRef ScalableVectorTypeRef := ⟨TypeRef.dump⟩

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
