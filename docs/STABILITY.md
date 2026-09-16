# MistUI v4 stability policy

MistUI 4.x treats documented public `Library`, `Window`, and `Card` methods as a frozen compatibility surface.

- Patch/minor releases may add APIs and fix behavior.
- A documented v4 public method must not be removed or renamed inside the v4 major line.
- `tests/public_api_snapshot.json` is the machine-checked baseline.
- Config schema remains 5 unless a future format change genuinely requires migration.
- Legacy `AddX` methods remain supported during v4; `Card:Add(type, config)` is the preferred stable surface.
- Breaking API changes are reserved for v5.

This policy protects source compatibility; it cannot guarantee that every executor/runtime implements every Roblox/executor primitive identically.
