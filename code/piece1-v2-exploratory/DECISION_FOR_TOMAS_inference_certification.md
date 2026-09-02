# Open decision for Tomás — how the randomization test is computed, and whether the paper needs the belt-and-suspenders version

**Date:** 2026-09-01 (Abhijit + Claude session)

## What we do now (the fast, verified version)

The randomization test recomputes the treatment effect under 9,999 fake rollout
assignments, each with seventeen estimator evaluations (full sample plus the
leave-one-region-out ones used to studentize). Running the `did` package itself
for every evaluation costs roughly 60 hours of compute per exhibit. Instead, the
test uses an exact reimplementation of the estimator's arithmetic — same
comparisons, same weights, same averaging — which runs in minutes.

The safeguard: before any fake draw is scored, the reimplementation's answer on
the real data must equal the package's answer to machine precision (agreement at
the eighth decimal or better), or the run halts. Every exhibit we show passed
this gate in every cell.

**Proposed disclosure line for the paper:** "The randomization distribution is
computed via an exact reimplementation of the estimator, verified to reproduce
the package output to machine precision."

## The belt-and-suspenders alternative (your call)

Run the package itself on every one of the 9,999 x 17 evaluations, for the final
numbers only — about 60 hours of compute on Abhijit's machine, checkpointed (a
partial run already sits on disk and resumes). It proves the shortcut changed
nothing, at the cost of compute time whenever the final specification moves.

**Decision needed:** is the verified-reimplementation disclosure sufficient for
the paper, or should the final exhibit be certified by the full package-per-draw
run before submission?
