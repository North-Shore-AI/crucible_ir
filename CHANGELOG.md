# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-11-26

### Added

- Initial release of CrucibleIR
- Core experiment definition structs:
  - `CrucibleIR.Experiment` - Top-level experiment definition
  - `CrucibleIR.BackendRef` - LLM backend reference
  - `CrucibleIR.DatasetRef` - Dataset reference
  - `CrucibleIR.StageDef` - Processing stage definition
  - `CrucibleIR.OutputSpec` - Output specification
- Reliability configuration structs:
  - `CrucibleIR.Reliability.Config` - Container for all reliability configs
  - `CrucibleIR.Reliability.Ensemble` - Ensemble voting configuration
  - `CrucibleIR.Reliability.Hedging` - Request hedging configuration
  - `CrucibleIR.Reliability.Stats` - Statistical testing configuration
  - `CrucibleIR.Reliability.Fairness` - Fairness checking configuration
  - `CrucibleIR.Reliability.Guardrail` - Security guardrails configuration
- JSON serialization support via `Jason.Encoder` for all structs
- Full type specifications with `@type` and `@spec`
- Comprehensive documentation with examples
- `CrucibleIR.new_experiment/1` convenience function
- Test coverage: 78 tests (3 doctests, 75 unit tests), 0 failures

### Design Decisions

- All structs are immutable
- JSON-first approach for serialization
- Hierarchical configuration structure
- Required fields enforced with `@enforce_keys`
- Optional fields default to `nil` or sensible defaults

[Unreleased]: https://github.com/North-Shore-AI/crucible_ir/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/North-Shore-AI/crucible_ir/releases/tag/v0.1.0
