# Protocol Sentinel v1 protected CI pilot

This is a **test-only** branch of the existing v0.5 Treasury consumer; `main` stays on the historical reference.
The v1 tool revision is Git-pinned to `c3f7b556626dafe11a9de284dcc87b82a825b98a`.

This pinned Direct UUPS Treasury test uses the existing `test_SafeUpgradePreservesRestriction` producer, with declared actor and UUPS candidate; source-controlled `sentinel.toml` is matched to a protected policy v2.
The protected-base helper checks the exact PR merge commit and approved Sentinel gitlink before running candidate Sentinel code. It writes only the tested commit SHA into the policy instance.
The workflow compiles with consumer-pinned Forge sources, resolves an explicit solc 0.8.24 executable, runs independent replay, and retains Evidence on BLOCK.

For acceptance, open unmerged PRs **against this pilot base**:
- Safe: change only non-protected pilot documentation; expect trusted gate PASS.
- Synthetic faulty: change the selected producer to transition to `ConsumerTreasuryV2Unsafe` instead of V2Safe; producer should execute, replay MATCH and gate BLOCK.
- Workflow bypass: replace the v1 gate job body with `exit 0`; protected integrity must fail.
- Tool pin bypass: change the Sentinel gitlink; preflight and integrity must fail.
- Failure/stale Evidence: stop the current producer, expect VERIFICATION FAILED and failure.

A required status name or green Actions job is not merge enforcement. Verify branch rules, owner-review requirements, and bypass resistance independently; no such claim is made by this branch. Never merge synthetic faulty or bypass PRs.
