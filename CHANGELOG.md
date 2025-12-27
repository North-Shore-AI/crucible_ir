# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2025-12-26

### Added

- Examples directory with API integration demos (backends, datasets, model registry, training, deployment, feedback, outputs, serialization)
- IR boundary documentation (`docs/20251226/ir_boundary/`)
- JSON round-trip tests for model lifecycle, deployment, feedback, and output specs

### Changed

- Serialization now decodes experiment model lifecycle fields and reliability feedback configs
- Serialization now normalizes dataset formats, stage modules, backend deployment IDs, and ensemble weights
- Documentation clarifies the IR boundary and serialization contract

## [0.2.0] - 2025-12-25

### Added

- **Model Lifecycle Structs**
  - `CrucibleIR.ModelRef` - Model reference with provider, framework, and artifact URI
  - `CrucibleIR.ModelVersion` - Model version with stage, metrics, and lineage tracking
  - `CrucibleIR.Training.Config` - Training configuration (epochs, batch size, optimizer, device)
  - `CrucibleIR.Training.Run` - Training run tracking (status, metrics history, checkpoints)
  - `CrucibleIR.Deployment.Config` - Deployment configuration (environment, strategy, scaling)
  - `CrucibleIR.Deployment.Status` - Deployment status (state, health, replicas)
  - `CrucibleIR.Feedback.Config` - Feedback collection configuration (sampling, storage, drift detection)
  - `CrucibleIR.Feedback.Event` - Feedback event (input, output, user feedback, latency)

## [0.1.1] - 2025-11-26

### Added

- **Validation Module** (`CrucibleIR.Validation`)
  - `validate/1` - Validates structs and returns `{:ok, struct}` or `{:error, errors}`
  - `valid?/1` - Returns boolean indicating validity
  - `errors/1` - Returns list of validation errors
  - Validates all IR structs including nested configurations
  - Validates enum values (strategies, execution modes, etc.)
  - Validates numeric ranges (alpha between 0 and 1)
  - Provides detailed, actionable error messages
  - 41 comprehensive validation tests

- **Serialization Module** (`CrucibleIR.Serialization`)
  - `to_json/1` - Encodes structs to JSON strings
  - `from_json/2` - Decodes JSON to typed structs with automatic conversion
  - `from_map/2` - Converts maps (string or atom keys) to structs
  - Handles nested struct deserialization (Experiment → BackendRef, Reliability.Config, etc.)
  - Automatic string-to-atom conversion for identifiers
  - Smart dataset name handling (preserves strings with spaces, converts simple names to atoms)
  - Round-trip serialization preserves data integrity
  - 26 comprehensive serialization tests including round-trip tests

- **Builder Module** (`CrucibleIR.Builder`)
  - Fluent, chainable API for experiment construction
  - `experiment/1` - Creates new experiment builder
  - `with_description/2` - Adds description
  - `with_backend/2` - Configures backend with options
  - `add_stage/2` - Adds pipeline stages
  - `with_dataset/2` - Configures dataset
  - `with_ensemble/2` - Adds ensemble voting configuration
  - `with_hedging/2` - Adds request hedging configuration
  - `with_stats/2` - Adds statistical testing configuration
  - `with_fairness/1` - Adds fairness checking configuration
  - `with_guardrails/1` - Adds security guardrails configuration
  - `add_output/2` - Adds output specifications
  - `build/1` - Validates and finalizes experiment
  - All builder methods are chainable
  - Automatic validation on `build/1`
  - 29 comprehensive builder tests

- **Main Module Delegations**
  - `CrucibleIR.validate/1` delegates to `Validation.validate/1`
  - `CrucibleIR.valid?/1` delegates to `Validation.valid?/1`
  - `CrucibleIR.to_json/1` delegates to `Serialization.to_json/1`
  - `CrucibleIR.from_json/2` delegates to `Serialization.from_json/2`
  - `CrucibleIR.from_map/2` delegates to `Serialization.from_map/2`
  - `CrucibleIR.experiment/1` delegates to `Builder.experiment/1`

- **Documentation**
  - Comprehensive module documentation with examples
  - Updated README with v0.1.1 feature examples
  - Validation examples
  - Serialization examples
  - Builder API examples
  - 3 new doctests (in addition to existing 3)

### Changed

- Test coverage increased from 78 to 174 tests (96 new tests)
- Documentation coverage remains at 100%

### Technical Details

- All new modules follow existing patterns (immutability, type specs, comprehensive docs)
- Zero compilation warnings
- All tests pass with zero failures
- Backward compatible with v0.1.0

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

[Unreleased]: https://github.com/North-Shore-AI/crucible_ir/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/North-Shore-AI/crucible_ir/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/North-Shore-AI/crucible_ir/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/North-Shore-AI/crucible_ir/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/North-Shore-AI/crucible_ir/releases/tag/v0.1.0
