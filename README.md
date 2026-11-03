# Protocol Sentinel — External Treasury Consumer

Independent Foundry integration for
[Protocol Sentinel](https://github.com/NothernZhongKui/protocol-sentinel).

Demonstrates Direct EOA/UUPS authority regression checks
using consumer-owned Treasury contracts and tests.

The portable runner produces Evidence and independently
replays classification and compiler outputs.

The CI producer records observed behavior without
asserting a safe verdict. The separate
`test_ExpectSafeUpgradeRestriction` test asserts the
safe fixture's expected result.

This allows a successful producer execution to report
a real authority regression through Evidence and a
trusted CI `BLOCK` decision.

The CI policy distinguishes:

- STILL_SATISFIED → PASS
- CHANGED_TO_VIOLATION → BLOCK

The workflow uses an unprivileged pull_request event,
a pinned Sentinel dependency and a policy read from
the PR base revision.

A repository ruleset must enforce the required check
and code-owner reviews before treating CI as
a protected merge boundary.
