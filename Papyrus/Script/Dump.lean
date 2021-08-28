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

instance : DumpRef ValueRef := ⟨ValueRef.dump⟩
instance : DumpRef UserRef := ⟨ValueRef.dump⟩
instance : DumpRef ConstantRef := ⟨ValueRef.dump⟩
instance : DumpRef ConstantIntRef := ⟨ValueRef.dump⟩
instance : DumpRef ConstantDataArrayRef := ⟨ValueRef.dump⟩
instance : DumpRef FunctionRef := ⟨ValueRef.dump⟩
instance : DumpRef GlobalValueRef := ⟨ValueRef.dump⟩
instance : DumpRef GlobalObjectRef := ⟨ValueRef.dump⟩
instance : DumpRef GlobalVariableRef := ⟨ValueRef.dump⟩

instance : DumpRef InstructionRef := ⟨ValueRef.dump⟩
instance : DumpRef ReturnInstRef := ⟨ValueRef.dump⟩

instance : DumpRef ModuleRef := ⟨ModuleRef.dump⟩

-- # Dump Command

macro kw:"#dump " x:term : command => do
  mkEvalAt kw <| ← ``(LlvmM.run ($x >>= dump))
