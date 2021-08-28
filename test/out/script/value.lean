import Papyrus.Script.Value

open Papyrus Script

#check show ModuleM PUnit from do
  let x ← llvm false
  let x ← llvm true
  let x ← llvm i32 0
  let x ← llvm i64 -1
  let x ← llvm "hello"*
  let x ← llvm "hello" addrspace(5) *
  let x ← llvm %x
  pure ()
