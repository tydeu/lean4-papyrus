import TestLib.AssertT

namespace TestLib

structure Test (m) where
  name : String
  run : AssertT m PUnit

structure Suite (m) where
  tests       : Array (Test m)
  beforeAll   : m PUnit
  beforeEach  : m PUnit
  afterEach   : m PUnit
  afterAll    : m PUnit

def Suite.empty [Pure m] : Suite m := {
  tests       := #[]
  beforeAll   := pure ()
  beforeEach  := pure ()
  afterEach   := pure ()
  afterAll    := pure ()
}

instance [Pure m] : Inhabited (Suite m) := ⟨Suite.empty⟩

def Suite.appendTest (test : Test m) (self : Suite m) : Suite m :=
  {self with tests := self.tests.push test}

def Suite.appendBeforeAll [SeqRight m] (action : m PUnit) (self : Suite m) : Suite m :=
  {self with beforeAll := self.beforeAll *> action}

def Suite.appendBeforeEach [SeqRight m] (action : m PUnit) (self : Suite m) : Suite m :=
  {self with beforeEach := self.beforeEach *> action}

def Suite.appendAfterEach [SeqRight m] (action : m PUnit) (self : Suite m) : Suite m :=
 {self with afterEach := self.afterEach *> action}

def Suite.appendAfterAll [SeqRight m] (action : m PUnit) (self : Suite m) : Suite m :=
 {self with afterAll := self.afterAll *> action}

/--
  Run the tests in this suite,
  returning an array of failing tests and their errors in the suite monad.
-/
def Suite.run [Monad m] (self : Suite m) : m (Array (Test m × AssertionError)) := do
  let mut failures := #[]
  self.beforeAll
  for test in self.tests do
    self.beforeEach
    match (← test.run) with
    | Except.ok _ => pure ()
    | Except.error e =>
      failures := failures.push (test, e)
    self.afterEach
  self.afterAll
  return failures

/-- Run the tests in this suite, printing out results along the way. -/
def Suite.runIO
[Monad m] [MonadLiftT IO m] [MonadExceptOf IO.Error m] (self : Suite m)
: m PUnit := do
  let mut passCount := 0
  let mut failCount := 0
  try self.beforeAll catch e =>
    IO.eprintln s!"unexpected exception in before all callback: {e}"
  for test in self.tests do
    IO.println s!"Running {test.name} ..."
    try self.beforeEach catch e =>
      IO.eprintln s!"unexpected exception in before each callback: {e}"
    try
      match (← test.run) with
      | Except.ok _ =>
        passCount := passCount + 1
      | Except.error e =>
        IO.eprintln e.message
        failCount := failCount + 1
    catch e : IO.Error =>
      IO.eprintln s!"unexpected exception in test: {e}"
    try self.afterEach catch e =>
      IO.eprintln s!"unexpected exception in after each callback: {e}"
  try self.afterAll catch e =>
    IO.eprintln s!"unexpected exception in before all callback: {e}"
  IO.println s!"Tests finished. {passCount} passed. {failCount} failed."

-- # Suite Monad

abbrev SuiteT (m) := StateM (Suite m)

def SuiteT.runIO
[Monad m] [MonadLiftT IO m] [MonadExceptOf IO.Error m] (self : SuiteT m PUnit)
: m PUnit := do
  StateT.run self Suite.empty |>.run.2.runIO

def beforeAll [SeqRight m] (action : m PUnit) : SuiteT m PUnit :=
  modify fun suite => suite.appendBeforeAll action

def beforeEach [SeqRight m] (action : m PUnit) : SuiteT m PUnit :=
  modify fun suite => suite.appendBeforeEach action

def test (name : String) (action : AssertT m PUnit) : SuiteT m PUnit :=
  modify fun suite => suite.appendTest ⟨name, action⟩

def afterEach [SeqRight m] (action : m PUnit) : SuiteT m PUnit :=
  modify fun suite => suite.appendAfterAll action

def afterAll [SeqRight m] (action : m PUnit) : SuiteT m PUnit :=
  modify fun suite => suite.appendAfterAll action
