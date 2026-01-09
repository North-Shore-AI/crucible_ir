# CrucibleIR Boundary and Contract

Date: 2025-12-26
Status: Draft
Owner: North-Shore-AI

## 1) Purpose

Define the strict boundary for `crucible_ir` so that it remains a pure, portable representation of ML lifecycle specs without execution logic. This avoids confusion between IR and runtime behavior.

## 2) Non-Negotiable Boundary Rules

### Allowed in `crucible_ir`
- Structs representing specs, configuration, and lifecycle metadata.
- JSON serialization/deserialization utilities.
- Validation helpers that only inspect struct fields.
- Small builders that construct structs from data.

### Not Allowed in `crucible_ir`
- Execution code (runners, pipelines, training logic).
- Stage implementations or orchestration logic.
- Network calls or storage backends.
- Side effects beyond pure data conversion and validation.

## 3) Canonical IR Scope

`crucible_ir` defines:
- Experiment specs (`CrucibleIR.Experiment`)
- Backend IR (`CrucibleIR.Backend.Prompt`, `CrucibleIR.Backend.Options`, `CrucibleIR.Backend.Completion`, `CrucibleIR.Backend.Capabilities`)
- Stage defs (`CrucibleIR.StageDef`)
- Training configs (`CrucibleIR.Training.Config`)
- Deployment configs (`CrucibleIR.Deployment.Config`)
- Feedback configs (`CrucibleIR.Feedback.Config`)
- Model registry structs (`CrucibleIR.ModelRef`, `CrucibleIR.ModelVersion`)

It does not define *how* these are executed.

## 4) Stage Options Contract

- `StageDef.options` is an opaque map.
- `crucible_ir` does not validate or coerce stage options.
- Validation for stage options belongs to stage implementations in domain packages.

## 5) Serialization Contract

- All IR structs must be `@derive Jason.Encoder`.
- `CrucibleIR.Serialization` is the canonical JSON round-trip layer.
- JSON keys should be stable; new fields must be optional and backward compatible.

## 6) Versioning and Compatibility

- Only additive changes to existing structs in minor versions.
- Breaking changes require a major version and migration notes.
- Avoid structural changes that break JSON round-trip without migration.

## 7) Acceptance Criteria

- No runner or execution code appears in `crucible_ir`.
- All stages and orchestration live in `crucible_framework` or domain packages.
- IR structs remain serializable, validated, and portable across the ecosystem.
