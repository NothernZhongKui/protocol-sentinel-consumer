# Sentinel CI smoke test

This documentation-only change exercises the external
Treasury consumer's real GitHub Actions gate.

Expected outcome:

- Producer: Success
- Independent classification replay: MATCH
- Compiler replay: MATCH
- Authority comparison: STILL_SATISFIED
- CI policy decision: PASS
- Exit code: 0
