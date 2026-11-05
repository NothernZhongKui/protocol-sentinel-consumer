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

## Observed GitHub Actions evidence (2026-11-05 UTC)

| Candidate | Workflow run | Observation |
| --- | --- | --- |
| [Safe PR #10](https://github.com/NothernZhongKui/protocol-sentinel-consumer/pull/10) | [42061646180](https://github.com/NothernZhongKui/protocol-sentinel-consumer/actions/runs/42061646180) | Fresh producer, Git source attestation, 42 contracts independently replayed, STILL_SATISFIED, MATCH, PASS (exit 0) |
| [Synthetic faulty PR #11](https://github.com/NothernZhongKui/protocol-sentinel-consumer/pull/11) | [42061812476](https://github.com/NothernZhongKui/protocol-sentinel-consumer/actions/runs/42061812476) | Fresh producer, Git source attestation, 42 contracts independently replayed, CHANGED_TO_VIOLATION, MATCH, BLOCK (exit 2) |
| [Failed producer PR #12](https://github.com/NothernZhongKui/protocol-sentinel-consumer/pull/12) | [42062309488](https://github.com/NothernZhongKui/protocol-sentinel-consumer/actions/runs/42062309488) | Intentional producer revert, no completed Evidence, VERIFICATION FAILED, exit 2 |
| [Gitlink substitution PR #13](https://github.com/NothernZhongKui/protocol-sentinel-consumer/pull/13) | [42062438030](https://github.com/NothernZhongKui/protocol-sentinel-consumer/actions/runs/42062438030) | Preflight rejected substituted v0.5 tool before candidate Python, exit 2 |

**Not yet proven:** repository merge prevention under required status checks, workflow body substitution, CODEOWNERS/owner approval enforcement, or an unassisted external developer onboarding. The `pull_request_target` integrity workflow introduced only on this non-default pilot base is **not** evidence of an active protected integrity check: GitHub requires that event's workflow file to be present on the default branch. This pilot is therefore **not** a protected-merge acceptance. Do not merge the faulty or bypass PRs.

For a meaningful enforcement acceptance, install the integrity policy on a protected/default-branch-controlled workflow or centrally managed required workflow; configure rulesets with required gate and integrity checks, restricted bypass permissions and required CODEOWNERS approval for producer/fixture changes. Then exercise an ordinary contributor PR that replaces the workflow job with `exit 0`, as well as a tool-pin mutation, and confirm GitHub rejects merge. Record the exact ruleset and check contexts.
