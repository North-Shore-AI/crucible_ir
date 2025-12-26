# CrucibleIR Gap Analysis

**Date**: 2025-12-25
**Version**: 0.1.1 (current)
**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir`

## Executive Summary

CrucibleIR currently provides solid IR for ML reliability experiments but lacks support for the emerging MLOps lifecycle components: model training, model registry, deployment, and feedback loops. This document identifies gaps that need to be addressed to support `crucible_train`, `crucible_model_registry`, `crucible_deployment`, and `crucible_feedback`.

---

## 1. Missing IR Types for New Ecosystem Components

### 1.1 Model Training (crucible_train)

**Missing Structs**:

| Struct | Purpose | Priority |
|--------|---------|----------|
| `TrainingConfig` | Training hyperparameters and settings | HIGH |
| `TrainingRun` | Represents a training execution | HIGH |
| `CheckpointRef` | Reference to model checkpoint | HIGH |
| `OptimizerConfig` | Optimizer settings (Adam, SGD, etc.) | MEDIUM |
| `SchedulerConfig` | Learning rate scheduler | MEDIUM |
| `DataLoaderConfig` | Batch size, shuffling, workers | MEDIUM |
| `LossConfig` | Loss function configuration | MEDIUM |
| `EarlyStoppingConfig` | Early stopping criteria | LOW |
| `RegularizationConfig` | Dropout, weight decay, etc. | LOW |

**Required Fields for TrainingConfig**:
```elixir
defstruct [
  :id,                    # atom() - Training config identifier
  :model_ref,             # ModelRef.t() - Reference to model definition
  :dataset_ref,           # DatasetRef.t() - Training dataset
  :optimizer,             # OptimizerConfig.t() - Optimizer settings
  :scheduler,             # SchedulerConfig.t() | nil - LR scheduler
  :epochs,                # pos_integer() - Number of epochs
  :batch_size,            # pos_integer() - Batch size
  :learning_rate,         # float() - Initial learning rate
  :loss_function,         # atom() - Loss function type
  :metrics,               # [atom()] - Metrics to track
  :validation_split,      # float() | nil - Validation split ratio
  :seed,                  # integer() | nil - Random seed
  :device,                # atom() - :cpu | :cuda | :mps
  :mixed_precision,       # boolean() - Use mixed precision
  :gradient_accumulation, # pos_integer() | nil - Gradient accumulation steps
  :gradient_clipping,     # float() | nil - Max gradient norm
  :options                # map() | nil - Additional options
]
```

### 1.2 Model Registry (crucible_model_registry)

**Missing Structs**:

| Struct | Purpose | Priority |
|--------|---------|----------|
| `ModelRef` | Reference to a registered model | HIGH |
| `ModelVersion` | Specific version of a model | HIGH |
| `ModelArtifact` | Path/location of model files | HIGH |
| `ModelMetadata` | Model description, author, license | HIGH |
| `ModelLineage` | Parent model, fine-tuning history | MEDIUM |
| `ModelSignature` | Input/output schemas | MEDIUM |
| `ModelTag` | Tagging for model discovery | LOW |

**Required Fields for ModelRef**:
```elixir
defstruct [
  :id,              # atom() | String.t() - Model identifier
  :name,            # String.t() - Human-readable name
  :version,         # String.t() | nil - Semantic version
  :provider,        # atom() - :local | :huggingface | :openai | :s3
  :artifact_uri,    # String.t() | nil - Path to model artifacts
  :framework,       # atom() - :nx | :pytorch | :onnx | :safetensors
  :architecture,    # atom() | nil - Model architecture type
  :task,            # atom() | nil - :text_classification | :generation | etc
  :metadata,        # map() | nil - Additional metadata
  :created_at,      # DateTime.t() | nil
  :options          # map() | nil
]
```

**Required Fields for ModelVersion**:
```elixir
defstruct [
  :id,              # atom() - Version identifier
  :model_ref,       # ModelRef.t() - Parent model
  :version,         # String.t() - Semantic version (e.g., "1.2.3")
  :stage,           # atom() - :development | :staging | :production | :archived
  :training_run_id, # atom() | nil - Reference to training run
  :metrics,         # map() - Performance metrics
  :artifact_uri,    # String.t() - Path to this version's artifacts
  :parent_version,  # String.t() | nil - Parent version for lineage
  :description,     # String.t() | nil
  :created_at,      # DateTime.t()
  :created_by,      # String.t() | nil
  :options          # map() | nil
]
```

### 1.3 Deployment (crucible_deployment)

**Missing Structs**:

| Struct | Purpose | Priority |
|--------|---------|----------|
| `DeploymentConfig` | Deployment specification | HIGH |
| `DeploymentTarget` | Where to deploy (k8s, lambda, etc.) | HIGH |
| `ResourceSpec` | CPU, memory, GPU requirements | HIGH |
| `ScalingConfig` | Auto-scaling configuration | MEDIUM |
| `HealthCheckConfig` | Health check settings | MEDIUM |
| `EndpointConfig` | API endpoint configuration | MEDIUM |
| `CanaryConfig` | Canary deployment settings | LOW |
| `RollbackConfig` | Rollback criteria and settings | LOW |

**Required Fields for DeploymentConfig**:
```elixir
defstruct [
  :id,              # atom() - Deployment identifier
  :model_version,   # ModelVersion.t() - Model version to deploy
  :target,          # DeploymentTarget.t() - Deployment target
  :resources,       # ResourceSpec.t() - Resource requirements
  :replicas,        # pos_integer() - Number of replicas
  :scaling,         # ScalingConfig.t() | nil - Auto-scaling
  :health_check,    # HealthCheckConfig.t() | nil
  :endpoint,        # EndpointConfig.t() | nil - API configuration
  :environment,     # atom() - :development | :staging | :production
  :strategy,        # atom() - :rolling | :blue_green | :canary
  :canary,          # CanaryConfig.t() | nil
  :rollback,        # RollbackConfig.t() | nil
  :metadata,        # map() | nil
  :created_at,      # DateTime.t() | nil
  :options          # map() | nil
]
```

**Required Fields for DeploymentTarget**:
```elixir
defstruct [
  :type,            # atom() - :kubernetes | :docker | :lambda | :fly | :local
  :cluster,         # String.t() | nil - Cluster name
  :namespace,       # String.t() | nil - K8s namespace
  :region,          # String.t() | nil - Cloud region
  :credentials_ref, # atom() | nil - Reference to credentials
  :options          # map() | nil
]
```

### 1.4 Feedback Loop (crucible_feedback)

**Missing Structs**:

| Struct | Purpose | Priority |
|--------|---------|----------|
| `FeedbackEvent` | Individual feedback data point | HIGH |
| `FeedbackConfig` | Feedback collection configuration | HIGH |
| `LabelingTask` | Human labeling task definition | MEDIUM |
| `CorrectionEvent` | User correction of model output | MEDIUM |
| `DriftDetectionConfig` | Data/model drift detection | MEDIUM |
| `RetrainingTrigger` | Conditions to trigger retraining | MEDIUM |
| `ABTestConfig` | A/B testing configuration | LOW |

**Required Fields for FeedbackEvent**:
```elixir
defstruct [
  :id,              # String.t() - Unique event ID
  :deployment_id,   # atom() - Source deployment
  :model_version,   # String.t() - Model version
  :input,           # map() - Model input
  :output,          # map() - Model output
  :feedback_type,   # atom() - :thumbs | :rating | :correction | :label
  :feedback_value,  # term() - The actual feedback
  :user_id,         # String.t() | nil - User who provided feedback
  :session_id,      # String.t() | nil - Session context
  :latency_ms,      # pos_integer() | nil - Response latency
  :timestamp,       # DateTime.t() - When feedback was received
  :metadata,        # map() | nil
  :options          # map() | nil
]
```

**Required Fields for FeedbackConfig**:
```elixir
defstruct [
  :enabled,         # boolean() - Whether feedback is enabled
  :sampling_rate,   # float() - Percentage of requests to sample
  :feedback_types,  # [atom()] - Types of feedback to collect
  :storage,         # atom() - :postgres | :s3 | :bigquery
  :retention_days,  # pos_integer() | nil - How long to retain
  :anonymize_pii,   # boolean() - Whether to anonymize PII
  :drift_detection, # DriftDetectionConfig.t() | nil
  :retraining,      # RetrainingTrigger.t() | nil
  :options          # map() | nil
]
```

---

## 2. Existing Struct Updates Required

### 2.1 Experiment Struct

**Current**: Experiment focuses on evaluation experiments only.

**Updates Needed**:
```elixir
# Add to Experiment struct:
:experiment_type,     # atom() - :evaluation | :training | :comparison | :ablation
:model_version,       # ModelVersion.t() | nil - Model being evaluated
:training_config,     # TrainingConfig.t() | nil - For training experiments
:baseline_model,      # ModelRef.t() | nil - For comparison experiments
:ab_test_config,      # ABTestConfig.t() | nil - For A/B testing
```

### 2.2 BackendRef Struct

**Current**: References LLM backends by ID and profile.

**Updates Needed**:
```elixir
# Add to BackendRef struct:
:model_version,       # String.t() | nil - Specific model version
:endpoint_url,        # String.t() | nil - Custom endpoint URL
:deployment_id,       # atom() | nil - Link to deployment
:fallback_backend,    # BackendRef.t() | nil - Fallback if primary fails
:rate_limit,          # map() | nil - Rate limiting config
:retry_config,        # map() | nil - Retry configuration
```

### 2.3 DatasetRef Struct

**Current**: Basic dataset reference with provider/split.

**Updates Needed**:
```elixir
# Add to DatasetRef struct:
:version,             # String.t() | nil - Dataset version
:format,              # atom() | nil - :parquet | :csv | :jsonl | :arrow
:schema,              # map() | nil - Expected schema
:validation_rules,    # [map()] | nil - Data validation rules
:preprocessing,       # [atom()] | nil - Preprocessing steps to apply
:cache_policy,        # atom() | nil - :always | :never | :if_local
```

### 2.4 OutputSpec Struct

**Current**: Basic output format and sink.

**Updates Needed**:
```elixir
# Add to OutputSpec struct:
:compression,         # atom() | nil - :gzip | :snappy | :none
:partitioning,        # map() | nil - Partitioning scheme
:retention_policy,    # map() | nil - Retention settings
:encryption,          # boolean() | nil - Whether to encrypt
:notification,        # map() | nil - Notification on completion
```

### 2.5 Reliability.Config Struct

**Current**: Has ensemble, hedging, stats, fairness, guardrails.

**Updates Needed**:
```elixir
# Add to Reliability.Config struct:
:monitoring,          # MonitoringConfig.t() | nil - Runtime monitoring
:drift,               # DriftDetectionConfig.t() | nil - Drift detection
:circuit_breaker,     # CircuitBreakerConfig.t() | nil - Circuit breaker
:rate_limiting,       # RateLimitConfig.t() | nil - Rate limiting
:caching,             # CacheConfig.t() | nil - Response caching
```

---

## 3. Validation Gaps

### 3.1 Missing Validation Rules

| Struct | Missing Validation |
|--------|-------------------|
| `Experiment` | No validation for dataset compatibility with pipeline |
| `BackendRef` | No validation for profile existence |
| `DatasetRef` | No validation for provider compatibility |
| `StageDef` | No validation that module implements expected behaviour |
| `Stats` | No validation for test compatibility |
| `Ensemble` | No validation that models list is non-empty when strategy != :none |

### 3.2 Cross-Struct Validation Needed

- Validate that ensemble models match backend type
- Validate that dataset split exists in provider
- Validate that output formats are compatible with sink
- Validate that hedging strategy makes sense with ensemble mode
- Validate that fairness group_by attribute exists in dataset schema

---

## 4. Serialization Gaps

### 4.1 Missing Serialization Support

- No support for custom struct serialization hooks
- No support for partial deserialization (e.g., just extract ID)
- No streaming serialization for large payloads
- No schema versioning for backwards compatibility

### 4.2 Type Conversion Issues

- DateTime serialization doesn't preserve timezone
- Module atoms may not round-trip correctly
- Large nested structs may exceed JSON limits

---

## 5. Builder API Gaps

### 5.1 Missing Builder Functions

For new structs:
- `with_model_version(exp, version)`
- `with_training_config(exp, config)`
- `with_deployment(exp, deployment)`
- `with_feedback_config(exp, config)`
- `with_monitoring(exp, config)`

### 5.2 Builder Improvements Needed

- No `update_` variants for modifying existing fields
- No `remove_` variants for removing optional fields
- No `merge_` for combining multiple configs
- No builder for reliability configs in isolation

---

## 6. Documentation Gaps

### 6.1 Missing Documentation

- No architecture decision records (ADRs)
- No migration guide for version upgrades
- No integration examples with other Crucible projects
- No performance considerations documentation

### 6.2 README Updates Needed

- Add section for new MLOps lifecycle structs
- Add examples for training/deployment workflows
- Update architecture diagram
- Add version compatibility matrix

---

## 7. Testing Gaps

### 7.1 Missing Test Coverage

- No property-based tests for serialization round-trips
- No edge case tests for validation boundaries
- No integration tests with external systems
- No performance/benchmark tests

### 7.2 Test Infrastructure Needs

- Shared test fixtures/factories
- Test helper for creating valid complex structs
- Mock/stub helpers for backend simulation

---

## 8. Credo/Dialyzer Considerations

### 8.1 Potential Issues

- Large structs may trigger complexity warnings
- Deeply nested types may be hard for Dialyzer
- Some type specs may be incomplete

### 8.2 Recommended Practices

- Use `@moduledoc false` for internal modules
- Define custom types for complex unions
- Use `@dialyzer` attributes sparingly

---

## 9. Priority Matrix

| Gap | Impact | Effort | Priority |
|-----|--------|--------|----------|
| ModelRef/ModelVersion structs | HIGH | MEDIUM | P0 |
| TrainingConfig struct | HIGH | MEDIUM | P0 |
| DeploymentConfig struct | HIGH | MEDIUM | P0 |
| FeedbackEvent struct | HIGH | MEDIUM | P0 |
| Experiment struct updates | MEDIUM | LOW | P1 |
| BackendRef struct updates | MEDIUM | LOW | P1 |
| New validation rules | MEDIUM | MEDIUM | P1 |
| Cross-struct validation | MEDIUM | HIGH | P2 |
| Builder API extensions | LOW | MEDIUM | P2 |
| Documentation updates | LOW | LOW | P2 |
| Property-based tests | LOW | MEDIUM | P3 |

---

## 10. Recommended Implementation Order

1. **Phase 1**: Core MLOps Structs
   - Add ModelRef, ModelVersion
   - Add TrainingConfig, TrainingRun
   - Add corresponding tests and validation

2. **Phase 2**: Deployment & Feedback
   - Add DeploymentConfig, DeploymentTarget, ResourceSpec
   - Add FeedbackEvent, FeedbackConfig
   - Add corresponding tests and validation

3. **Phase 3**: Update Existing Structs
   - Extend Experiment for training/deployment workflows
   - Extend BackendRef for deployment integration
   - Extend DatasetRef for versioning

4. **Phase 4**: Reliability Extensions
   - Add MonitoringConfig, DriftDetectionConfig
   - Add CircuitBreakerConfig, RateLimitConfig
   - Update Reliability.Config

5. **Phase 5**: Builder & Documentation
   - Extend Builder API
   - Update README and docs
   - Add integration examples

---

## 11. Backwards Compatibility Notes

- All new fields should be optional with `nil` defaults
- New structs should not break existing serialization
- Validation should only fail for invalid new fields, not missing ones
- Consider adding `@optional_callbacks` for new behaviors
