# Prompt: Enforce CrucibleIR Boundary and Contract

Date: 2025-12-26

## Goal

Implement the boundary contract defined in:
- `/home/home/p/g/North-Shore-AI/crucible_ir/docs/20251226/ir_boundary/IR_BOUNDARY_AND_CONTRACT.md`

Ensure `crucible_ir` remains pure IR (structs + serialization + validation only).

## Required Reading (Full Paths)

- `/home/home/p/g/North-Shore-AI/crucible_ir/README.md`
- `/home/home/p/g/North-Shore-AI/crucible_ir/CHANGELOG.md`
- `/home/home/p/g/North-Shore-AI/crucible_ir/mix.exs`
- `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir.ex`
- `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/experiment.ex`
- `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/stage_def.ex`
- `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/serialization.ex`
- `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/validation.ex`
- `/home/home/p/g/North-Shore-AI/crucible_ir/docs/20251226/ir_boundary/IR_BOUNDARY_AND_CONTRACT.md`

## Context Summary

`crucible_ir` must remain strictly data-only. All execution logic belongs in `crucible_framework` or domain packages. Stage options are opaque maps; validation happens in stages, not in IR.

## Implementation Requirements

1) Audit the repo for any execution logic, orchestration helpers, or side effects.
2) Remove or relocate anything that violates the boundary.
3) Update docs to clarify boundary rules and serialization contract if needed.
4) Add tests for JSON round-trip stability where missing.

## TDD and Quality Gates

- Write tests first where behavior is added or enforced.
- `mix test` must pass.
- `mix compile --warnings-as-errors` must be clean.
- `mix format` must be clean.
- `mix credo --strict` must be clean.
- `mix dialyzer` must be clean.

## Version Bump (Required)

- Bump version `0.x.y` in `/home/home/p/g/North-Shore-AI/crucible_ir/mix.exs`.
- Update `/home/home/p/g/North-Shore-AI/crucible_ir/README.md` to reflect the new version.
- Add a 2025-12-26 entry to `/home/home/p/g/North-Shore-AI/crucible_ir/CHANGELOG.md`.

