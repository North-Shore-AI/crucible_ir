# CrucibleIR Enhancement Implementation Prompt

**Date**: 2025-12-25
**Target Version**: 0.2.0
**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir`

---

## Mission

Extend CrucibleIR to support the complete ML lifecycle including training, model registry, deployment, and feedback loops. This enables integration with `crucible_train`, `crucible_model_registry`, `crucible_deployment`, and `crucible_feedback`.

---

## Required Reading (Full Paths)

Before making any changes, read and understand these files:

### Core Source Files
```
/home/home/p/g/North-Shore-AI/crucible_ir/mix.exs
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/experiment.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/backend_ref.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/stage_def.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/dataset_ref.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/output_spec.ex
```

### Reliability Configuration Files
```
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/config.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/ensemble.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/hedging.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/stats.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/fairness.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/guardrail.ex
```

### Utility Files
```
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/validation.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/serialization.ex
/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/builder.ex
```

### Test Files (for patterns)
```
/home/home/p/g/North-Shore-AI/crucible_ir/test/crucible_ir_test.exs
/home/home/p/g/North-Shore-AI/crucible_ir/test/crucible_ir/experiment_test.exs
/home/home/p/g/North-Shore-AI/crucible_ir/test/crucible_ir/validation_test.exs
/home/home/p/g/North-Shore-AI/crucible_ir/test/crucible_ir/serialization_test.exs
/home/home/p/g/North-Shore-AI/crucible_ir/test/crucible_ir/builder_test.exs
/home/home/p/g/North-Shore-AI/crucible_ir/test/crucible_ir/reliability_test.exs
```

### Documentation
```
/home/home/p/g/North-Shore-AI/crucible_ir/README.md
/home/home/p/g/North-Shore-AI/crucible_ir/docs/20251225/current_state.md
/home/home/p/g/North-Shore-AI/crucible_ir/docs/20251225/gaps.md
```

---

## Current Struct Definitions Reference

### CrucibleIR.Experiment (Current)
```elixir
@enforce_keys [:id, :backend, :pipeline]
defstruct [
  :id,            # atom() - Required. Unique experiment identifier
  :backend,       # BackendRef.t() - Required. LLM backend to evaluate
  :pipeline,      # [StageDef.t()] - Required. List of processing stages
  :description,   # String.t() | nil
  :owner,         # String.t() | nil
  :tags,          # [atom()] | nil
  :metadata,      # map() | nil
  :dataset,       # DatasetRef.t() | nil
  :reliability,   # Reliability.Config.t() | nil
  :outputs,       # [OutputSpec.t()] | nil
  :created_at,    # DateTime.t() | nil
  :updated_at     # DateTime.t() | nil
]
```

### CrucibleIR.BackendRef (Current)
```elixir
@enforce_keys [:id]
defstruct [
  :id,                  # atom() - Required. Backend identifier
  profile: :default,    # atom()
  options: nil          # map() | nil
]
```

### CrucibleIR.DatasetRef (Current)
```elixir
@enforce_keys [:name]
defstruct [
  :name,                        # atom() | String.t() - Required
  provider: :crucible_datasets, # atom()
  split: :train,                # atom()
  options: nil                  # map() | nil
]
```

### CrucibleIR.StageDef (Current)
```elixir
@enforce_keys [:name]
defstruct [
  :name,          # atom() - Required
  :module,        # module() | nil
  :options,       # map() | nil
  enabled: true   # boolean()
]
```

### CrucibleIR.OutputSpec (Current)
```elixir
@enforce_keys [:name]
defstruct [
  :name,                 # atom() - Required
  :options,              # map() | nil
  formats: [:markdown],  # [format()]
  sink: :file            # sink()
]
```

### CrucibleIR.Reliability.Config (Current)
```elixir
defstruct ensemble: nil,    # Ensemble.t() | nil
          hedging: nil,     # Hedging.t() | nil
          guardrails: nil,  # Guardrail.t() | nil
          stats: nil,       # Stats.t() | nil
          fairness: nil     # Fairness.t() | nil
```

---

## Implementation Tasks

### Phase 1: Model Registry Structs

#### Task 1.1: Create ModelRef

**File**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/model_ref.ex`

```elixir
defmodule CrucibleIR.ModelRef do
  @moduledoc """
  Reference to a registered model in the model registry.

  A `ModelRef` identifies a specific model that can be used for training,
  evaluation, or deployment. It supports multiple providers and frameworks.

  ## Fields

  - `:id` - Model identifier (required)
  - `:name` - Human-readable model name
  - `:version` - Semantic version string
  - `:provider` - Model source/provider
  - `:framework` - ML framework
  - `:architecture` - Model architecture type
  - `:task` - ML task type
  - `:artifact_uri` - Path to model artifacts
  - `:metadata` - Additional metadata
  - `:options` - Provider-specific options

  ## Examples

      iex> ref = %CrucibleIR.ModelRef{id: :gpt2_base, provider: :huggingface}
      iex> ref.provider
      :huggingface
  """

  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :version,
    :artifact_uri,
    :architecture,
    :task,
    :metadata,
    provider: :local,
    framework: :nx,
    options: nil
  ]

  @type provider :: :local | :huggingface | :openai | :anthropic | :s3 | :gcs | atom()
  @type framework :: :nx | :pytorch | :tensorflow | :onnx | :safetensors | atom()
  @type task :: :text_classification | :text_generation | :embedding | :qa | :summarization | atom()
  @type architecture :: :transformer | :lstm | :cnn | :mlp | atom()

  @type t :: %__MODULE__{
          id: atom() | String.t(),
          name: String.t() | nil,
          version: String.t() | nil,
          provider: provider(),
          framework: framework(),
          architecture: architecture() | nil,
          task: task() | nil,
          artifact_uri: String.t() | nil,
          metadata: map() | nil,
          options: map() | nil
        }
end
```

**Test File**: `/home/home/p/g/North-Shore-AI/crucible_ir/test/crucible_ir/model_ref_test.exs`

Write tests for:
- Struct creation with required fields
- Default values
- JSON encoding/decoding
- All provider/framework/task types

#### Task 1.2: Create ModelVersion

**File**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/model_version.ex`

```elixir
defmodule CrucibleIR.ModelVersion do
  @moduledoc """
  Specific version of a registered model.

  A `ModelVersion` represents a concrete, immutable snapshot of a model
  at a specific point in time, with associated metrics and lineage.

  ## Fields

  - `:id` - Version identifier (required)
  - `:model_id` - Parent model ID (required)
  - `:version` - Semantic version string (required)
  - `:stage` - Deployment stage
  - `:training_run_id` - Reference to training run
  - `:metrics` - Performance metrics
  - `:artifact_uri` - Path to version artifacts
  - `:parent_version` - Parent version for lineage
  - `:description` - Version description
  - `:created_at` - Creation timestamp
  - `:created_by` - Creator identifier
  - `:options` - Additional options

  ## Examples

      iex> version = %CrucibleIR.ModelVersion{
      ...>   id: :v1_0_0,
      ...>   model_id: :gpt2_base,
      ...>   version: "1.0.0",
      ...>   stage: :production
      ...> }
      iex> version.stage
      :production
  """

  @derive Jason.Encoder
  @enforce_keys [:id, :model_id, :version]
  defstruct [
    :id,
    :model_id,
    :version,
    :training_run_id,
    :metrics,
    :artifact_uri,
    :parent_version,
    :description,
    :created_at,
    :created_by,
    stage: :development,
    options: nil
  ]

  @type stage :: :development | :staging | :production | :archived | atom()

  @type t :: %__MODULE__{
          id: atom(),
          model_id: atom() | String.t(),
          version: String.t(),
          stage: stage(),
          training_run_id: atom() | nil,
          metrics: map() | nil,
          artifact_uri: String.t() | nil,
          parent_version: String.t() | nil,
          description: String.t() | nil,
          created_at: DateTime.t() | nil,
          created_by: String.t() | nil,
          options: map() | nil
        }
end
```

### Phase 2: Training Structs

#### Task 2.1: Create TrainingConfig

**File**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/training/config.ex`

```elixir
defmodule CrucibleIR.Training.Config do
  @moduledoc """
  Configuration for model training.

  Defines hyperparameters, optimizer settings, and training options
  for a training run.

  ## Fields

  - `:id` - Config identifier (required)
  - `:model_ref` - Reference to model to train (required)
  - `:dataset_ref` - Training dataset (required)
  - `:epochs` - Number of training epochs
  - `:batch_size` - Batch size
  - `:learning_rate` - Initial learning rate
  - `:optimizer` - Optimizer type
  - `:loss_function` - Loss function
  - `:metrics` - Metrics to track
  - `:validation_split` - Validation data ratio
  - `:device` - Compute device
  - `:seed` - Random seed
  - `:mixed_precision` - Use mixed precision
  - `:gradient_clipping` - Max gradient norm
  - `:early_stopping` - Early stopping config
  - `:checkpoint_every` - Checkpoint frequency
  - `:options` - Additional options

  ## Examples

      iex> config = %CrucibleIR.Training.Config{
      ...>   id: :train_gpt2,
      ...>   model_ref: %CrucibleIR.ModelRef{id: :gpt2},
      ...>   dataset_ref: %CrucibleIR.DatasetRef{name: :wikitext},
      ...>   epochs: 10,
      ...>   batch_size: 32
      ...> }
      iex> config.epochs
      10
  """

  alias CrucibleIR.{ModelRef, DatasetRef}

  @derive Jason.Encoder
  @enforce_keys [:id, :model_ref, :dataset_ref]
  defstruct [
    :id,
    :model_ref,
    :dataset_ref,
    :validation_split,
    :seed,
    :gradient_clipping,
    :early_stopping,
    :checkpoint_every,
    epochs: 1,
    batch_size: 32,
    learning_rate: 0.001,
    optimizer: :adam,
    loss_function: :cross_entropy,
    metrics: [:loss, :accuracy],
    device: :cpu,
    mixed_precision: false,
    options: nil
  ]

  @type optimizer :: :adam | :sgd | :adamw | :rmsprop | atom()
  @type loss :: :cross_entropy | :mse | :mae | :bce | atom()
  @type device :: :cpu | :cuda | :mps | :tpu | atom()

  @type t :: %__MODULE__{
          id: atom(),
          model_ref: ModelRef.t(),
          dataset_ref: DatasetRef.t(),
          epochs: pos_integer(),
          batch_size: pos_integer(),
          learning_rate: float(),
          optimizer: optimizer(),
          loss_function: loss(),
          metrics: [atom()],
          validation_split: float() | nil,
          device: device(),
          seed: integer() | nil,
          mixed_precision: boolean(),
          gradient_clipping: float() | nil,
          early_stopping: map() | nil,
          checkpoint_every: pos_integer() | nil,
          options: map() | nil
        }
end
```

#### Task 2.2: Create TrainingRun

**File**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/training/run.ex`

```elixir
defmodule CrucibleIR.Training.Run do
  @moduledoc """
  Represents a training execution.

  A `TrainingRun` tracks the execution of a training configuration,
  including status, metrics, artifacts, and timing information.

  ## Fields

  - `:id` - Run identifier (required)
  - `:config` - Training configuration (required)
  - `:status` - Current run status
  - `:current_epoch` - Current training epoch
  - `:metrics_history` - Metrics over time
  - `:best_metrics` - Best achieved metrics
  - `:checkpoint_uris` - Saved checkpoint paths
  - `:final_model_version` - Resulting model version
  - `:started_at` - Start timestamp
  - `:completed_at` - Completion timestamp
  - `:error_message` - Error if failed
  - `:options` - Additional options

  ## Examples

      iex> run = %CrucibleIR.Training.Run{
      ...>   id: :run_001,
      ...>   config: training_config,
      ...>   status: :running
      ...> }
      iex> run.status
      :running
  """

  alias CrucibleIR.Training.Config

  @derive Jason.Encoder
  @enforce_keys [:id, :config]
  defstruct [
    :id,
    :config,
    :current_epoch,
    :metrics_history,
    :best_metrics,
    :checkpoint_uris,
    :final_model_version,
    :started_at,
    :completed_at,
    :error_message,
    status: :pending,
    options: nil
  ]

  @type status :: :pending | :running | :completed | :failed | :cancelled | atom()

  @type t :: %__MODULE__{
          id: atom(),
          config: Config.t(),
          status: status(),
          current_epoch: pos_integer() | nil,
          metrics_history: [map()] | nil,
          best_metrics: map() | nil,
          checkpoint_uris: [String.t()] | nil,
          final_model_version: atom() | nil,
          started_at: DateTime.t() | nil,
          completed_at: DateTime.t() | nil,
          error_message: String.t() | nil,
          options: map() | nil
        }
end
```

### Phase 3: Deployment Structs

#### Task 3.1: Create DeploymentConfig

**File**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/deployment/config.ex`

```elixir
defmodule CrucibleIR.Deployment.Config do
  @moduledoc """
  Configuration for model deployment.

  Defines where and how a model version should be deployed,
  including resource requirements and scaling settings.

  ## Fields

  - `:id` - Deployment identifier (required)
  - `:model_version_id` - Model version to deploy (required)
  - `:target` - Deployment target configuration
  - `:replicas` - Number of replicas
  - `:resources` - Resource requirements
  - `:scaling` - Auto-scaling configuration
  - `:environment` - Target environment
  - `:strategy` - Deployment strategy
  - `:health_check` - Health check settings
  - `:endpoint` - API endpoint configuration
  - `:metadata` - Additional metadata
  - `:options` - Additional options

  ## Examples

      iex> config = %CrucibleIR.Deployment.Config{
      ...>   id: :deploy_prod,
      ...>   model_version_id: :v1_0_0,
      ...>   environment: :production
      ...> }
      iex> config.environment
      :production
  """

  @derive Jason.Encoder
  @enforce_keys [:id, :model_version_id]
  defstruct [
    :id,
    :model_version_id,
    :target,
    :resources,
    :scaling,
    :health_check,
    :endpoint,
    :metadata,
    replicas: 1,
    environment: :development,
    strategy: :rolling,
    options: nil
  ]

  @type environment :: :development | :staging | :production | atom()
  @type strategy :: :rolling | :blue_green | :canary | :recreate | atom()

  @type t :: %__MODULE__{
          id: atom(),
          model_version_id: atom(),
          target: map() | nil,
          replicas: pos_integer(),
          resources: map() | nil,
          scaling: map() | nil,
          environment: environment(),
          strategy: strategy(),
          health_check: map() | nil,
          endpoint: map() | nil,
          metadata: map() | nil,
          options: map() | nil
        }
end
```

#### Task 3.2: Create DeploymentStatus

**File**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/deployment/status.ex`

```elixir
defmodule CrucibleIR.Deployment.Status do
  @moduledoc """
  Status of an active deployment.

  Tracks the current state of a deployment including health,
  traffic routing, and replica status.

  ## Fields

  - `:id` - Status identifier (required)
  - `:deployment_id` - Associated deployment (required)
  - `:state` - Current deployment state
  - `:ready_replicas` - Number of ready replicas
  - `:total_replicas` - Total number of replicas
  - `:endpoint_url` - Active endpoint URL
  - `:traffic_percent` - Percentage of traffic
  - `:health` - Health status
  - `:last_health_check` - Last health check timestamp
  - `:error_message` - Error if unhealthy
  - `:created_at` - Creation timestamp
  - `:updated_at` - Last update timestamp

  ## Examples

      iex> status = %CrucibleIR.Deployment.Status{
      ...>   id: :status_001,
      ...>   deployment_id: :deploy_prod,
      ...>   state: :active
      ...> }
      iex> status.state
      :active
  """

  @derive Jason.Encoder
  @enforce_keys [:id, :deployment_id]
  defstruct [
    :id,
    :deployment_id,
    :ready_replicas,
    :total_replicas,
    :endpoint_url,
    :traffic_percent,
    :last_health_check,
    :error_message,
    :created_at,
    :updated_at,
    state: :pending,
    health: :unknown
  ]

  @type state :: :pending | :deploying | :active | :degraded | :failed | :terminated | atom()
  @type health :: :unknown | :healthy | :unhealthy | :degraded | atom()

  @type t :: %__MODULE__{
          id: atom(),
          deployment_id: atom(),
          state: state(),
          ready_replicas: pos_integer() | nil,
          total_replicas: pos_integer() | nil,
          endpoint_url: String.t() | nil,
          traffic_percent: float() | nil,
          health: health(),
          last_health_check: DateTime.t() | nil,
          error_message: String.t() | nil,
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }
end
```

### Phase 4: Feedback Structs

#### Task 4.1: Create FeedbackEvent

**File**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/feedback/event.ex`

```elixir
defmodule CrucibleIR.Feedback.Event do
  @moduledoc """
  Individual feedback data point.

  Represents user feedback on model output, which can be used
  for model improvement and monitoring.

  ## Fields

  - `:id` - Event identifier (required)
  - `:deployment_id` - Source deployment
  - `:model_version` - Model version string
  - `:input` - Model input
  - `:output` - Model output
  - `:feedback_type` - Type of feedback
  - `:feedback_value` - Feedback value/content
  - `:user_id` - User identifier
  - `:session_id` - Session identifier
  - `:latency_ms` - Response latency
  - `:timestamp` - Event timestamp
  - `:metadata` - Additional metadata

  ## Examples

      iex> event = %CrucibleIR.Feedback.Event{
      ...>   id: "evt_123",
      ...>   feedback_type: :thumbs,
      ...>   feedback_value: :up
      ...> }
      iex> event.feedback_type
      :thumbs
  """

  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :deployment_id,
    :model_version,
    :input,
    :output,
    :feedback_value,
    :user_id,
    :session_id,
    :latency_ms,
    :metadata,
    feedback_type: :thumbs,
    timestamp: nil
  ]

  @type feedback_type :: :thumbs | :rating | :correction | :label | :flag | atom()

  @type t :: %__MODULE__{
          id: String.t(),
          deployment_id: atom() | nil,
          model_version: String.t() | nil,
          input: map() | nil,
          output: map() | nil,
          feedback_type: feedback_type(),
          feedback_value: term(),
          user_id: String.t() | nil,
          session_id: String.t() | nil,
          latency_ms: pos_integer() | nil,
          timestamp: DateTime.t() | nil,
          metadata: map() | nil
        }
end
```

#### Task 4.2: Create FeedbackConfig

**File**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/feedback/config.ex`

```elixir
defmodule CrucibleIR.Feedback.Config do
  @moduledoc """
  Configuration for feedback collection.

  Defines how feedback should be collected, stored, and processed.

  ## Fields

  - `:enabled` - Whether feedback collection is enabled
  - `:sampling_rate` - Percentage of requests to sample
  - `:feedback_types` - Types of feedback to collect
  - `:storage` - Storage backend
  - `:retention_days` - Data retention period
  - `:anonymize_pii` - Whether to anonymize PII
  - `:drift_detection` - Drift detection settings
  - `:retraining_trigger` - Retraining trigger settings
  - `:options` - Additional options

  ## Examples

      iex> config = %CrucibleIR.Feedback.Config{
      ...>   enabled: true,
      ...>   sampling_rate: 0.1
      ...> }
      iex> config.sampling_rate
      0.1
  """

  @derive Jason.Encoder
  defstruct [
    :retention_days,
    :drift_detection,
    :retraining_trigger,
    enabled: false,
    sampling_rate: 1.0,
    feedback_types: [:thumbs, :correction],
    storage: :postgres,
    anonymize_pii: true,
    options: nil
  ]

  @type storage :: :postgres | :s3 | :bigquery | :local | atom()

  @type t :: %__MODULE__{
          enabled: boolean(),
          sampling_rate: float(),
          feedback_types: [atom()],
          storage: storage(),
          retention_days: pos_integer() | nil,
          anonymize_pii: boolean(),
          drift_detection: map() | nil,
          retraining_trigger: map() | nil,
          options: map() | nil
        }
end
```

### Phase 5: Update Existing Structs

#### Task 5.1: Update Experiment

Update `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/experiment.ex`:

Add these optional fields (keep backwards compatible):
```elixir
# Add to defstruct (after existing fields):
:experiment_type,     # atom() - :evaluation | :training | :comparison | :ablation
:model_version,       # ModelVersion.t() | nil - Model being evaluated
:training_config,     # Training.Config.t() | nil - For training experiments
:baseline,            # ModelRef.t() | nil - Baseline for comparison
```

Update the type spec accordingly.

#### Task 5.2: Update BackendRef

Update `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/backend_ref.ex`:

Add these optional fields:
```elixir
# Add to defstruct (after existing fields):
:model_version,       # String.t() | nil - Specific model version
:endpoint_url,        # String.t() | nil - Custom endpoint URL
:deployment_id,       # atom() | nil - Link to deployment
:fallback,            # BackendRef.t() | nil - Fallback backend
```

#### Task 5.3: Update DatasetRef

Update `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/dataset_ref.ex`:

Add these optional fields:
```elixir
# Add to defstruct (after existing fields):
:version,             # String.t() | nil - Dataset version
:format,              # atom() | nil - :parquet | :csv | :jsonl | :arrow
:schema,              # map() | nil - Expected schema
```

#### Task 5.4: Update Reliability.Config

Update `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/config.ex`:

Add these optional fields:
```elixir
# Add to defstruct (after existing fields):
:monitoring,          # map() | nil - Runtime monitoring config
:drift,               # map() | nil - Drift detection config
:circuit_breaker,     # map() | nil - Circuit breaker config
:feedback,            # Feedback.Config.t() | nil - Feedback collection config
```

### Phase 6: Update Validation

Update `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/validation.ex`:

Add validation functions for new structs:
```elixir
def validate(%ModelRef{} = model), do: validate_model_ref(model)
def validate(%ModelVersion{} = version), do: validate_model_version(version)
def validate(%Training.Config{} = config), do: validate_training_config(config)
def validate(%Training.Run{} = run), do: validate_training_run(run)
def validate(%Deployment.Config{} = config), do: validate_deployment_config(config)
def validate(%Deployment.Status{} = status), do: validate_deployment_status(status)
def validate(%Feedback.Event{} = event), do: validate_feedback_event(event)
def validate(%Feedback.Config{} = config), do: validate_feedback_config(config)

# Validation rules:
# - ModelRef: id required
# - ModelVersion: id, model_id, version required; version must match semver pattern
# - Training.Config: id, model_ref, dataset_ref required; epochs, batch_size > 0; learning_rate > 0
# - Training.Run: id, config required; status must be valid
# - Deployment.Config: id, model_version_id required; replicas > 0
# - Deployment.Status: id, deployment_id required; state must be valid
# - Feedback.Event: id required
# - Feedback.Config: sampling_rate between 0 and 1
```

### Phase 7: Update Serialization

Update `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/serialization.ex`:

Add `from_map/2` implementations for all new structs following the existing pattern.

### Phase 8: Update Builder

Update `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/builder.ex`:

Add these new builder functions:
```elixir
@spec with_model_version(builder_experiment(), atom()) :: builder_experiment()
def with_model_version(%Experiment{} = exp, version_id) do
  # Implementation
end

@spec with_training_config(builder_experiment(), keyword()) :: builder_experiment()
def with_training_config(%Experiment{} = exp, opts) do
  # Implementation
end

@spec with_experiment_type(builder_experiment(), atom()) :: builder_experiment()
def with_experiment_type(%Experiment{} = exp, type) do
  # Implementation
end

@spec with_baseline(builder_experiment(), atom()) :: builder_experiment()
def with_baseline(%Experiment{} = exp, model_ref) do
  # Implementation
end

@spec with_feedback_config(builder_experiment(), keyword()) :: builder_experiment()
def with_feedback_config(%Experiment{} = exp, opts) do
  # Implementation
end
```

### Phase 9: Update Main Module

Update `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir.ex`:

Add aliases and documentation for new structs:
```elixir
# Update @moduledoc to document new components

# Add convenience functions:
@spec new_training_config(keyword()) :: Training.Config.t()
def new_training_config(attrs), do: struct!(Training.Config, attrs)

@spec new_model_ref(keyword()) :: ModelRef.t()
def new_model_ref(attrs), do: struct!(ModelRef, attrs)

@spec new_deployment_config(keyword()) :: Deployment.Config.t()
def new_deployment_config(attrs), do: struct!(Deployment.Config, attrs)
```

### Phase 10: Update README

Update `/home/home/p/g/North-Shore-AI/crucible_ir/README.md`:

- Update version to 0.2.0
- Add sections for:
  - Model Registry (ModelRef, ModelVersion)
  - Training (Training.Config, Training.Run)
  - Deployment (Deployment.Config, Deployment.Status)
  - Feedback (Feedback.Event, Feedback.Config)
- Add examples for training/deployment workflows
- Update architecture diagram
- Update test count

---

## TDD Approach

For each new struct/function:

1. **Write failing test first**
2. **Implement minimal code to pass**
3. **Refactor while keeping tests green**

### Test Template
```elixir
defmodule CrucibleIR.NewStructTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.NewStruct

  describe "struct creation" do
    test "creates with required fields" do
      # Test required fields
    end

    test "uses correct defaults" do
      # Test default values
    end

    test "accepts all optional fields" do
      # Test optional fields
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      # Test JSON encoding
    end

    test "round-trips correctly" do
      # Test encode -> decode
    end
  end
end
```

---

## Quality Requirements

### Before Each Commit:

```bash
# Must all pass
mix format --check-formatted
mix compile --warnings-as-errors
mix credo --strict
mix dialyzer
mix test
```

### Code Style:
- All public functions must have `@doc` and `@spec`
- All structs must have `@moduledoc` with examples
- All types must be defined with `@type`
- Follow existing patterns exactly

### Documentation:
- Every new struct needs moduledoc with fields list and examples
- Update README with new components
- Add doctest examples where appropriate

### Testing:
- 100% coverage for new code
- Tests for validation success and failure cases
- Tests for serialization round-trips
- Tests for builder functions

---

## File Locations Summary

### New Files to Create:
```
lib/crucible_ir/model_ref.ex
lib/crucible_ir/model_version.ex
lib/crucible_ir/training/config.ex
lib/crucible_ir/training/run.ex
lib/crucible_ir/deployment/config.ex
lib/crucible_ir/deployment/status.ex
lib/crucible_ir/feedback/event.ex
lib/crucible_ir/feedback/config.ex

test/crucible_ir/model_ref_test.exs
test/crucible_ir/model_version_test.exs
test/crucible_ir/training/config_test.exs
test/crucible_ir/training/run_test.exs
test/crucible_ir/deployment/config_test.exs
test/crucible_ir/deployment/status_test.exs
test/crucible_ir/feedback/event_test.exs
test/crucible_ir/feedback/config_test.exs
```

### Files to Update:
```
lib/crucible_ir.ex
lib/crucible_ir/experiment.ex
lib/crucible_ir/backend_ref.ex
lib/crucible_ir/dataset_ref.ex
lib/crucible_ir/reliability/config.ex
lib/crucible_ir/validation.ex
lib/crucible_ir/serialization.ex
lib/crucible_ir/builder.ex

test/crucible_ir/validation_test.exs
test/crucible_ir/serialization_test.exs
test/crucible_ir/builder_test.exs

mix.exs (version bump to 0.2.0)
README.md
```

---

## Verification Checklist

Before considering the implementation complete:

- [ ] All new structs created with proper types and docs
- [ ] All existing structs updated with new fields
- [ ] Validation functions added for all new structs
- [ ] Serialization functions added for all new structs
- [ ] Builder functions added for new experiment options
- [ ] All tests written and passing
- [ ] `mix format` passes
- [ ] `mix compile --warnings-as-errors` passes
- [ ] `mix credo --strict` passes
- [ ] `mix dialyzer` passes
- [ ] README.md updated with new components
- [ ] Version bumped to 0.2.0 in mix.exs
