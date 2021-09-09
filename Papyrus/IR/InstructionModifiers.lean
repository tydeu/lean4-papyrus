import Papyrus.Internal.Enum

namespace Papyrus

open Internal

/--
  Atomic ordering for LLVM's memory model.

  C++ defines ordering as a lattice.
  LLVM supplements this with NotAtomic and Unordered,
  which are both below the C++ orders.

  `not_atomic` --> `unordered` --> `relaxed` --> `release` ------------—>
    `acq_rel` --> `seq_cst` --> `consume` --> `acquire`
-/
inductive AtomicOrdering
| notAtomic
| unordered
| monotonic
| consume
| acquire
| release
| acquireRelease
| sequentiallyConsistent
deriving BEq, DecidableEq, Repr

attribute [unbox] AtomicOrdering
instance : Inhabited AtomicOrdering := ⟨AtomicOrdering.notAtomic⟩

/--
  Synchronization scope IDs.

  All synchronization scope IDs that LLVM has special knowledge of are listed here.
  However, there can be additional synchronization scopes not defined here.
-/
enum SyncScopeID : UInt32
| /-- Synchronized with respect to signal handlers executing in the same thread. -/
  singleThread := 0
| /-- Synchronized with respect to all concurrently executing threads (the default). -/
  system := 1
deriving BEq, DecidableEq, Repr

instance : Inhabited SyncScopeID := ⟨SyncScopeID.system⟩
