# Runtime compatibility matrix

This file intentionally records **only real executions**. Static analysis is not counted as runtime compatibility.

| Environment | Smoke | Quality | Stress | Benchmark | Notes |
|---|---:|---:|---:|---:|---|
| Roblox Studio / client | Not run here | Not run here | Not run here | Not run here | Run the scripts under `tests/` in your target environment. |
| Executor A | Not tested | Not tested | Not tested | Not tested | Fill after an actual run. |
| Executor B | Not tested | Not tested | Not tested | Not tested | Fill after an actual run. |
| Mobile/touch target | Not tested | Not tested | Not tested | Not tested | Verify touch, focus, mobile toggle and resize constraints. |

A release should not change a cell to Pass without executing that suite in the named environment.
