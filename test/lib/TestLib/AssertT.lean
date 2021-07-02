namespace TestLib

structure AssertionError where
  message : String

instance : ToString AssertionError := ⟨AssertionError.message⟩

abbrev AssertT := ExceptT AssertionError
