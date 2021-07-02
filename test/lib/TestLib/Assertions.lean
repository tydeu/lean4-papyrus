import TestLib.AssertT

namespace TestLib
variable {m} [Monad m]

def assertFail (message : String) : AssertT m PUnit :=
  throwThe AssertionError ⟨message⟩

def assertTrue (actual : Bool) : AssertT m PUnit  :=
  unless actual do
    assertFail "expected true, got false"

def assertFalse (actual : Bool) : AssertT m PUnit := do
  if actual then
    assertFail "expected false, got true"

def assertEq [Repr α] [DecidableEq α] (expected actual : α) : AssertT m PUnit := do
  unless expected = actual do
    assertFail s!"expected '{repr expected}', got '{repr actual}'"

def assertBEq [Repr α] [BEq α] (expected actual : α) : AssertT m PUnit := do
  unless expected == actual do
    assertFail s!"expected '{repr expected}', got '{repr actual}'"
