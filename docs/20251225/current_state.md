# CrucibleIR Current State Documentation

**Date**: 2025-12-25
**Version**: 0.1.1
**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir`

## Overview

CrucibleIR provides the Intermediate Representation (IR) for the Crucible ML reliability ecosystem. It defines shared data structures for ML reliability experiments, enabling consistency across all Crucible tools and components.

## Architecture Summary

```
CrucibleIR (Main Module)
    |
    +-- Experiment (top-level experiment definition)
    |       |-- BackendRef (LLM backend reference)
    |       |-- StageDef (pipeline stage definition)
    |       |-- DatasetRef (dataset reference)
    |       |-- OutputSpec (output specification)
    |       +-- Reliability.Config (reliability configurations)
    |               |-- Ensemble (multi-model voting)
    |               |-- Hedging (request hedging)
    |               |-- Stats (statistical testing)
    |               |-- Fairness (bias detection)
    |               +-- Guardrail (security guardrails)
    |
    +-- Validation (struct validation)
    +-- Serialization (JSON serialization/deserialization)
    +-- Builder (fluent API for experiment construction)
```

## Source Files

| File | Purpose |
|------|---------|
| `lib/crucible_ir.ex` | Main module with convenience functions and delegations |
| `lib/crucible_ir/experiment.ex` | Top-level experiment struct |
| `lib/crucible_ir/backend_ref.ex` | LLM backend reference struct |
| `lib/crucible_ir/stage_def.ex` | Pipeline stage definition struct |
| `lib/crucible_ir/dataset_ref.ex` | Dataset reference struct |
| `lib/crucible_ir/output_spec.ex` | Output specification struct |
| `lib/crucible_ir/reliability/config.ex` | Container for all reliability configs |
| `lib/crucible_ir/reliability/ensemble.ex` | Ensemble voting configuration |
| `lib/crucible_ir/reliability/hedging.ex` | Request hedging configuration |
| `lib/crucible_ir/reliability/stats.ex` | Statistical testing configuration |
| `lib/crucible_ir/reliability/fairness.ex` | Fairness checking configuration |
| `lib/crucible_ir/reliability/guardrail.ex` | Security guardrails configuration |
| `lib/crucible_ir/validation.ex` | Validation functions for all structs |
| `lib/crucible_ir/serialization.ex` | JSON serialization/deserialization |
| `lib/crucible_ir/builder.ex` | Fluent builder API |

---

## Complete Struct Definitions

### 1. CrucibleIR.Experiment

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/experiment.ex`

Top-level experiment definition.

```elixir
@enforce_keys [:id, :backend, :pipeline]
defstruct [
  :id,            # atom() - Required. Unique experiment identifier
  :backend,       # BackendRef.t() - Required. LLM backend to evaluate
  :pipeline,      # [StageDef.t()] - Required. List of processing stages
  :description,   # String.t() | nil - Human-readable description
  :owner,         # String.t() | nil - Experiment owner/creator
  :tags,          # [atom()] | nil - Tags for categorization
  :metadata,      # map() | nil - Additional metadata
  :dataset,       # DatasetRef.t() | nil - Dataset reference
  :reliability,   # Reliability.Config.t() | nil - Reliability configurations
  :outputs,       # [OutputSpec.t()] | nil - Output specifications
  :created_at,    # DateTime.t() | nil - Creation timestamp
  :updated_at     # DateTime.t() | nil - Update timestamp
]

@type t :: %__MODULE__{
  id: atom(),
  backend: BackendRef.t(),
  pipeline: [StageDef.t()],
  description: String.t() | nil,
  owner: String.t() | nil,
  tags: [atom()] | nil,
  metadata: map() | nil,
  dataset: DatasetRef.t() | nil,
  reliability: Config.t() | nil,
  outputs: [OutputSpec.t()] | nil,
  created_at: DateTime.t() | nil,
  updated_at: DateTime.t() | nil
}
```

### 2. CrucibleIR.BackendRef

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/backend_ref.ex`

Reference to an LLM backend.

```elixir
@enforce_keys [:id]
defstruct [
  :id,                  # atom() - Required. Backend identifier
  profile: :default,    # atom() - Configuration profile (default: :default)
  options: nil          # map() | nil - Backend-specific options
]

@type t :: %__MODULE__{
  id: atom(),
  profile: atom(),
  options: map() | nil
}
```

### 3. CrucibleIR.StageDef

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/stage_def.ex`

Processing stage definition in experiment pipeline.

```elixir
@enforce_keys [:name]
defstruct [
  :name,          # atom() - Required. Stage name/identifier
  :module,        # module() | nil - Module implementing this stage
  :options,       # map() | nil - Stage-specific configuration
  enabled: true   # boolean() - Whether stage is active (default: true)
]

@type t :: %__MODULE__{
  name: atom(),
  module: module() | nil,
  options: map() | nil,
  enabled: boolean()
}
```

### 4. CrucibleIR.DatasetRef

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/dataset_ref.ex`

Reference to a dataset.

```elixir
@enforce_keys [:name]
defstruct [
  :name,                        # atom() | String.t() - Required. Dataset name
  provider: :crucible_datasets, # atom() - Dataset provider (default: :crucible_datasets)
  split: :train,                # atom() - Dataset split (default: :train)
  options: nil                  # map() | nil - Dataset-specific options
]

@type provider :: :crucible_datasets | :huggingface | atom()
@type split :: :train | :test | :validation | atom()

@type t :: %__MODULE__{
  provider: provider(),
  name: atom(),
  split: split(),
  options: map() | nil
}
```

### 5. CrucibleIR.OutputSpec

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/output_spec.ex`

Output/reporting specification.

```elixir
@enforce_keys [:name]
defstruct [
  :name,                 # atom() - Required. Output name/identifier
  :options,              # map() | nil - Output-specific options
  formats: [:markdown],  # [format()] - Output formats (default: [:markdown])
  sink: :file            # sink() - Output destination (default: :file)
]

@type format :: :markdown | :json | :html | :latex | :csv | atom()
@type sink :: :file | :stdout | :s3 | :postgres | atom()

@type t :: %__MODULE__{
  name: atom(),
  formats: [format()],
  sink: sink(),
  options: map() | nil
}
```

### 6. CrucibleIR.Reliability.Config

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/config.ex`

Container for all reliability configurations.

```elixir
defstruct ensemble: nil,    # Ensemble.t() | nil - Ensemble voting config
          hedging: nil,     # Hedging.t() | nil - Request hedging config
          guardrails: nil,  # Guardrail.t() | nil - Security guardrails config
          stats: nil,       # Stats.t() | nil - Statistical testing config
          fairness: nil     # Fairness.t() | nil - Fairness checking config

@type t :: %__MODULE__{
  ensemble: Ensemble.t() | nil,
  hedging: Hedging.t() | nil,
  guardrails: Guardrail.t() | nil,
  stats: Stats.t() | nil,
  fairness: Fairness.t() | nil
}
```

### 7. CrucibleIR.Reliability.Ensemble

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/ensemble.ex`

Ensemble voting configuration.

```elixir
defstruct strategy: :none,        # strategy() - Voting strategy (default: :none)
          execution_mode: :parallel, # execution_mode() - How to execute (default: :parallel)
          models: nil,            # [atom()] | nil - Model identifiers
          weights: nil,           # map() | nil - Model weights for weighted voting
          min_agreement: nil,     # float() | nil - Minimum agreement threshold
          timeout_ms: nil,        # pos_integer() | nil - Execution timeout
          options: nil            # map() | nil - Additional options

@type strategy :: :none | :majority | :weighted | :best_confidence | :unanimous
@type execution_mode :: :parallel | :sequential | :hedged | :cascade

@type t :: %__MODULE__{
  strategy: strategy(),
  execution_mode: execution_mode(),
  models: [atom()] | nil,
  weights: map() | nil,
  min_agreement: float() | nil,
  timeout_ms: pos_integer() | nil,
  options: map() | nil
}
```

### 8. CrucibleIR.Reliability.Hedging

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/hedging.ex`

Request hedging configuration for tail latency reduction.

```elixir
defstruct strategy: :off,     # strategy() - Hedging strategy (default: :off)
          delay_ms: nil,      # pos_integer() | nil - Delay before hedge request
          percentile: nil,    # float() | nil - Target percentile
          max_hedges: nil,    # pos_integer() | nil - Maximum hedge requests
          budget_percent: nil, # number() | nil - Max cost increase allowed
          options: nil        # map() | nil - Additional options

@type strategy :: :off | :fixed | :percentile | :adaptive | :workload_aware

@type t :: %__MODULE__{
  strategy: strategy(),
  delay_ms: pos_integer() | nil,
  percentile: float() | nil,
  max_hedges: pos_integer() | nil,
  budget_percent: number() | nil,
  options: map() | nil
}
```

### 9. CrucibleIR.Reliability.Stats

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/stats.ex`

Statistical testing configuration.

```elixir
defstruct tests: [:ttest, :bootstrap], # [test()] - Statistical tests to run
          alpha: 0.05,                 # float() - Significance level
          confidence_level: nil,       # float() | nil - Confidence level for intervals
          effect_size_type: nil,       # effect_size() | nil - Effect size type
          multiple_testing_correction: nil, # correction() | nil - Correction method
          bootstrap_iterations: nil,   # pos_integer() | nil - Bootstrap iterations
          options: nil                 # map() | nil - Additional options

@type test :: :ttest | :bootstrap | :anova | :mannwhitney | :wilcoxon | :kruskal | atom()
@type effect_size :: :cohens_d | :eta_squared | :omega_squared | atom()
@type correction :: :bonferroni | :holm | :fdr | atom()

@type t :: %__MODULE__{
  tests: [test()],
  alpha: float(),
  confidence_level: float() | nil,
  effect_size_type: effect_size() | nil,
  multiple_testing_correction: correction() | nil,
  bootstrap_iterations: pos_integer() | nil,
  options: map() | nil
}
```

### 10. CrucibleIR.Reliability.Fairness

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/fairness.ex`

Fairness and bias detection configuration.

```elixir
defstruct enabled: false,      # boolean() - Whether enabled (default: false)
          metrics: nil,        # [metric()] | nil - Fairness metrics to compute
          group_by: nil,       # atom() | nil - Grouping attribute
          threshold: nil,      # float() | nil - Fairness threshold
          fail_on_violation: nil, # boolean() | nil - Fail on violations
          options: nil         # map() | nil - Additional options

@type metric :: :demographic_parity | :equalized_odds | :equal_opportunity | :predictive_parity | atom()

@type t :: %__MODULE__{
  enabled: boolean(),
  metrics: [metric()] | nil,
  group_by: atom() | nil,
  threshold: float() | nil,
  fail_on_violation: boolean() | nil,
  options: map() | nil
}
```

### 11. CrucibleIR.Reliability.Guardrail

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/reliability/guardrail.ex`

Security guardrails configuration.

```elixir
defstruct profiles: [:default],     # [profile()] - Security profiles (default: [:default])
          prompt_injection_detection: nil, # boolean() | nil - Detect injections
          jailbreak_detection: nil,   # boolean() | nil - Detect jailbreaks
          pii_detection: nil,         # boolean() | nil - Detect PII
          pii_redaction: nil,         # boolean() | nil - Redact PII
          content_moderation: nil,    # boolean() | nil - Moderate content
          fail_on_detection: nil,     # boolean() | nil - Fail on detection
          options: nil                # map() | nil - Additional options

@type profile :: :default | :strict | :moderate | :permissive | atom()

@type t :: %__MODULE__{
  profiles: [profile()],
  prompt_injection_detection: boolean() | nil,
  jailbreak_detection: boolean() | nil,
  pii_detection: boolean() | nil,
  pii_redaction: boolean() | nil,
  content_moderation: boolean() | nil,
  fail_on_detection: boolean() | nil,
  options: map() | nil
}
```

---

## Utility Modules

### CrucibleIR.Validation

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/validation.ex`

Provides validation for all IR structs.

**Public Functions**:
- `validate(struct)` - Returns `{:ok, struct}` or `{:error, [String.t()]}`
- `valid?(struct)` - Returns `true` or `false`
- `errors(struct)` - Returns list of error messages

**Validation Rules**:
- `Experiment`: id must be non-empty atom, backend required, pipeline must be non-empty list
- `BackendRef`: id must be non-nil atom
- `StageDef`: name must be non-nil atom
- `DatasetRef`: name must be non-empty when set as string
- `OutputSpec`: name must be non-nil atom
- `Ensemble`: strategy must be one of `:none, :majority, :weighted, :best_confidence, :unanimous`
- `Hedging`: strategy must be one of `:off, :fixed, :percentile, :adaptive, :workload_aware`
- `Stats`: alpha must be between 0 and 1

### CrucibleIR.Serialization

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/serialization.ex`

JSON serialization and deserialization.

**Public Functions**:
- `to_json(struct)` - Encodes struct to JSON string
- `from_json(json, type)` - Decodes JSON to struct of given type
- `from_map(map, type)` - Converts plain map to struct

**Supported Types**:
- All core structs (Experiment, BackendRef, StageDef, DatasetRef, OutputSpec)
- All reliability structs (Config, Ensemble, Hedging, Stats, Fairness, Guardrail)

### CrucibleIR.Builder

**Location**: `/home/home/p/g/North-Shore-AI/crucible_ir/lib/crucible_ir/builder.ex`

Fluent builder API for experiment construction.

**Public Functions**:
- `experiment(id)` - Creates new experiment builder
- `with_description(exp, description)` - Adds description
- `with_backend(exp, backend_id, opts \\ [])` - Adds backend
- `add_stage(exp, stage_name, opts \\ [])` - Adds pipeline stage
- `with_dataset(exp, dataset_name, opts \\ [])` - Adds dataset
- `with_ensemble(exp, strategy, opts \\ [])` - Adds ensemble config
- `with_hedging(exp, strategy, opts \\ [])` - Adds hedging config
- `with_stats(exp, tests, opts \\ [])` - Adds stats config
- `with_fairness(exp, opts \\ [])` - Adds fairness config
- `with_guardrails(exp, opts \\ [])` - Adds guardrails config
- `add_output(exp, name, opts \\ [])` - Adds output spec
- `build(exp)` - Validates and finalizes

---

## Dependencies

From `mix.exs`:
```elixir
defp deps do
  [
    {:jason, "~> 1.4"},
    {:ex_doc, "~> 0.31", only: :dev, runtime: false},
    {:dialyxir, "~> 1.4", only: [:dev], runtime: false}
  ]
end
```

## Test Coverage

**Test Files**:
- `test/crucible_ir_test.exs` - Main module tests
- `test/crucible_ir/experiment_test.exs` - Experiment struct tests
- `test/crucible_ir/backend_ref_test.exs` - BackendRef tests
- `test/crucible_ir/stage_def_test.exs` - StageDef tests
- `test/crucible_ir/dataset_ref_test.exs` - DatasetRef tests
- `test/crucible_ir/output_spec_test.exs` - OutputSpec tests
- `test/crucible_ir/reliability_test.exs` - Reliability config tests
- `test/crucible_ir/validation_test.exs` - Validation tests
- `test/crucible_ir/serialization_test.exs` - Serialization tests
- `test/crucible_ir/builder_test.exs` - Builder tests

**Test Stats**: 174 tests, 0 failures (6 doctests + 168 unit tests)

---

## Current Integrations

CrucibleIR is referenced by these ecosystem projects:
- crucible_harness - Experiment orchestration
- crucible_ensemble - Ensemble voting implementation
- crucible_hedging - Request hedging implementation
- crucible_bench - Statistical testing
- crucible_telemetry - Metrics and instrumentation
- crucible_trace - Causal transparency

---

## Design Patterns

1. **Immutable Structs**: All structs use Elixir's `defstruct` with `@derive Jason.Encoder`
2. **Required Fields**: Marked with `@enforce_keys`
3. **Type Safety**: Full `@type` specifications for all structs
4. **Default Values**: Sensible defaults where appropriate
5. **Nested Composition**: Reliability configs compose within Experiment
6. **Validation**: Pattern matching with accumulating errors
7. **Serialization**: Bidirectional JSON with atom/string conversion
