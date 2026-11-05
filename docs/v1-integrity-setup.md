# Default-branch integrity for the v1 pilot

This workflow is intentionally installed on the consumer's **default branch**, not solely on `pilot/v1-trusted-ci-base`. GitHub loads `pull_request_target` workflows from the default branch.

It handles PRs targeting `pilot/v1-trusted-ci-base` with only read-only token permissions, GitHub API metadata, and a fixed shell script. It does not check out or execute PR content. It blocks changes to workflows, policies, Foundry inputs, Git-linked dependencies, Solidity production sources and tests, including renamed paths.

**To enforce rather than just report:** configure a branch ruleset for `pilot/v1-trusted-ci-base` requiring both `Sentinel v1 Authority Gate` and `Sentinel v1 Policy Integrity` (GitHub Actions source), disallow bypass, require reviewed protected-file changes and keep PRs open until independent verification. The `Sentinel v1 Authority Gate` by itself is spoofable: see [synthetic PR #14](https://github.com/NothernZhongKui/protocol-sentinel-consumer/pull/14).

Protected source changes are intentionally blocked in this acceptance pilot. To update the expected producer, tool pin, policy or workflow, review and amend the protected pilot base separately; do not relax the integrity check in candidate PRs.

**Installation limitation:** adding this file to a feature branch does not activate the `pull_request_target` workflow. It must enter the default branch through the normal maintainer review process. This PR must not be force-merged through existing v0.5 integrity restrictions simply to make v1 tests pass.

This is a targeted pilot harness, not a claim of independently audited merge enforcement.
