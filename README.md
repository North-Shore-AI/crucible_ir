![CrucibleIR Hexagonal Mark](assets/crucible_ir.svg)

# CrucibleIR
[![Hex.pm](https://img.shields.io/hexpm/v/crucible_ir.svg)](https://hex.pm/packages/crucible_ir)
[![Docs](https://img.shields.io/badge/hexdocs-online-4ad5ff)](https://hexdocs.pm/crucible_ir)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Intermediate Representation for the Crucible ML reliability ecosystem.
Full docs: https://hexdocs.pm/crucible_ir

## Overview

`CrucibleIR` provides shared data structures for defining ML reliability experiments across the Crucible ecosystem. It serves as the common language for experiment configuration, enabling consistency across all Crucible tools and components.

## Requirements

- Elixir `~> 1.14` (and matching Erlang/OTP)
- `jason` for JSON encoding (included in deps)

## Features

- **Experiment Definition**: Complete experiment specifications with backends, pipelines, and datasets
- **Reliability Configurations**: Ensemble voting, hedging, statistical testing, fairness, and guardrails
- **Validation**: Built-in validation for all IR structs with detailed error messages
- **JSON Serialization**: Bidirectional JSON conversion with automatic type handling
- **Fluent Builder API**: Chainable, ergonomic experiment construction
- **Type Safety**: Full type specifications for all structs
- **Comprehensive Documentation**: 100% documentation coverage with examples

## Installation

Add `crucible_ir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:crucible_ir, "~> 0.2.0"}
  ]
end
```

Fetch dependencies:

```bash
mix deps.get
```

## Quick Start

```elixir
alias CrucibleIR.{Experiment, BackendRef, StageDef, DatasetRef}
alias CrucibleIR.Reliability.{Config, Ensemble, Stats}

# Define a simple experiment
experiment = CrucibleIR.new_experiment(
  id: :gpt4_benchmark,
  backend: %BackendRef{id: :openai_gpt4},
  pipeline: [
    %StageDef{name: :preprocessing},
    %StageDef{name: :inference},
    %StageDef{name: :evaluation}
  ],
  dataset: %DatasetRef{name: :mmlu, split: :test}
)

# Add reliability mechanisms
experiment = %{experiment |
  reliability: %Config{
    ensemble: %Ensemble{
      strategy: :majority,
      models: [:gpt4, :claude, :gemini],
      execution_mode: :parallel
    },
    stats: %Stats{
      tests: [:ttest, :bootstrap],
      alpha: 0.05
    }
  }
}

# Serialize to JSON
{:ok, json} = Jason.encode(experiment)
```

## Usage Workflow

1. Define an `Experiment` with `id`, `backend`, and `pipeline` stages.
2. Add a `DatasetRef` if the experiment targets a dataset.
3. Attach `Reliability.Config` options (ensemble, hedging, stats, fairness, guardrails).
4. Add `OutputSpec` entries to describe where and how to emit results.
5. Serialize with `Jason.encode/1` to pass the IR into other Crucible services.

## Core Components

### Experiment Definition

- **`Experiment`** - Top-level experiment definition
- **`BackendRef`** - Reference to an LLM backend
- **`DatasetRef`** - Reference to a dataset
- **`StageDef`** - Processing stage definition
- **`OutputSpec`** - Output specification

### Reliability Mechanisms

- **`Reliability.Config`** - Container for all reliability configurations
- **`Reliability.Ensemble`** - Multi-model ensemble voting
- **`Reliability.Hedging`** - Request hedging for tail latency reduction
- **`Reliability.Stats`** - Statistical testing configuration
- **`Reliability.Fairness`** - Fairness and bias detection
- **`Reliability.Guardrail`** - Security guardrails (prompt injection, PII, etc.)

## Struct Field Reference

- **Experiment**: required `id`, `backend`, `pipeline`; optional `description`, `owner`, `tags`, `metadata`, `dataset`, `reliability`, `outputs`, `created_at`, `updated_at`.
- **BackendRef**: required `id`; optional `profile` (default `:default`), `options`.
- **DatasetRef**: required `name`; optional `provider` (default `:crucible_datasets`), `split` (default `:train`), `options`.
- **StageDef**: required `name`; optional `module`, `options`, `enabled` (default `true`).
- **OutputSpec**: required `name`; optional `formats` (default `[:markdown]`), `sink` (default `:file`), `options`.
- **Reliability.Config**: optional `ensemble`, `hedging`, `stats`, `fairness`, `guardrails`.
  - **Ensemble**: `strategy` (default `:none`), `execution_mode` (default `:parallel`), `models`, `weights`, `min_agreement`, `timeout_ms`, `options`.
  - **Hedging**: `strategy` (default `:off`), `delay_ms`, `percentile`, `max_hedges`, `budget_percent`, `options`.
  - **Stats**: `tests` (default `[:ttest, :bootstrap]`), `alpha` (default `0.05`), `confidence_level`, `effect_size_type`, `multiple_testing_correction`, `bootstrap_iterations`, `options`.
  - **Fairness**: `enabled` (default `false`), `metrics`, `group_by`, `threshold`, `fail_on_violation`, `options`.
  - **Guardrail**: `profiles` (default `[:default]`), `prompt_injection_detection`, `jailbreak_detection`, `pii_detection`, `pii_redaction`, `content_moderation`, `fail_on_detection`, `options`.

## New in v0.1.1

### Validation

Validate experiments before execution:

```elixir
alias CrucibleIR.{Experiment, BackendRef, StageDef}

# Valid experiment
exp = %Experiment{
  id: :test,
  backend: %BackendRef{id: :gpt4},
  pipeline: [%StageDef{name: :run}]
}

{:ok, ^exp} = CrucibleIR.validate(exp)
true = CrucibleIR.valid?(exp)

# Invalid experiment
invalid = %Experiment{id: :test, backend: nil, pipeline: nil}
{:error, errors} = CrucibleIR.validate(invalid)
# errors: ["backend is required", "pipeline must be a list"]
```

### JSON Serialization

Serialize to/from JSON with automatic type conversion:

```elixir
alias CrucibleIR.{Experiment, BackendRef, StageDef}

# Create experiment
exp = %Experiment{
  id: :test,
  backend: %BackendRef{id: :gpt4},
  pipeline: [%StageDef{name: :inference}]
}

# Serialize to JSON
json = CrucibleIR.to_json(exp)

# Deserialize from JSON
{:ok, decoded} = CrucibleIR.from_json(json, Experiment)
decoded.id == :test  # true
decoded.backend.id == :gpt4  # true

# Works with nested structs and reliability configs
```

### Fluent Builder API

Build experiments with a chainable, ergonomic API:

```elixir
alias CrucibleIR.Builder

{:ok, exp} =
  Builder.experiment(:comprehensive_test)
  |> Builder.with_description("Production reliability test")
  |> Builder.with_backend(:gpt4, profile: :fast)
  |> Builder.add_stage(:preprocessing, options: %{normalize: true})
  |> Builder.add_stage(:inference)
  |> Builder.add_stage(:postprocessing)
  |> Builder.with_dataset(:mmlu, split: :test)
  |> Builder.with_ensemble(:majority, models: [:gpt4, :claude])
  |> Builder.with_hedging(:fixed, delay_ms: 100)
  |> Builder.with_stats([:ttest, :bootstrap], alpha: 0.01)
  |> Builder.with_fairness(metrics: [:demographic_parity], threshold: 0.8)
  |> Builder.with_guardrails(profiles: [:strict], pii_detection: true)
  |> Builder.add_output(:results, formats: [:json, :html])
  |> Builder.build()  # Validates and returns {:ok, exp} or {:error, errors}

# Builder automatically validates - build() returns errors if invalid
{:error, errors} =
  Builder.experiment(:invalid)
  |> Builder.build()  # Missing backend and pipeline
```

Or use the convenience function from the main module:

```elixir
{:ok, exp} =
  CrucibleIR.experiment(:my_test)
  |> Builder.with_backend(:gpt4)
  |> Builder.add_stage(:inference)
  |> Builder.build()
```

## Examples

### Ensemble Voting Experiment

```elixir
experiment = CrucibleIR.new_experiment(
  id: :ensemble_exp,
  backend: %BackendRef{id: :gpt4},
  pipeline: [%StageDef{name: :inference}],
  reliability: %Config{
    ensemble: %Ensemble{
      strategy: :weighted,
      models: [:gpt4, :claude, :gemini],
      weights: %{gpt4: 0.5, claude: 0.3, gemini: 0.2},
      execution_mode: :parallel
    }
  }
)
```

### Hedging for Low Latency

```elixir
experiment = CrucibleIR.new_experiment(
  id: :low_latency_exp,
  backend: %BackendRef{id: :gpt4},
  pipeline: [%StageDef{name: :inference}],
  reliability: %Config{
    hedging: %Hedging{
      strategy: :percentile,
      percentile: 0.95,
      max_hedges: 2,
      budget_percent: 15
    }
  }
)
```

### Statistical Testing

```elixir
experiment = CrucibleIR.new_experiment(
  id: :stats_exp,
  backend: %BackendRef{id: :gpt4},
  pipeline: [%StageDef{name: :inference}],
  dataset: %DatasetRef{name: :mmlu},
  reliability: %Config{
    stats: %Stats{
      tests: [:ttest, :mannwhitney, :bootstrap],
      alpha: 0.01,
      effect_size_type: :cohens_d,
      bootstrap_iterations: 10000
    }
  }
)
```

### Fairness Checking

```elixir
experiment = CrucibleIR.new_experiment(
  id: :fairness_exp,
  backend: %BackendRef{id: :gpt4},
  pipeline: [%StageDef{name: :inference}],
  reliability: %Config{
    fairness: %Fairness{
      enabled: true,
      metrics: [:demographic_parity, :equalized_odds],
      group_by: :gender,
      threshold: 0.8,
      fail_on_violation: true
    }
  }
)
```

### Security Guardrails

```elixir
experiment = CrucibleIR.new_experiment(
  id: :secure_exp,
  backend: %BackendRef{id: :gpt4},
  pipeline: [%StageDef{name: :inference}],
  reliability: %Config{
    guardrails: %Guardrail{
      profiles: [:strict],
      prompt_injection_detection: true,
      jailbreak_detection: true,
      pii_detection: true,
      pii_redaction: true,
      fail_on_detection: true
    }
  }
)
```

## Architecture

CrucibleIR follows a hierarchical structure:

```
Experiment (top-level)
├── BackendRef (which LLM to use)
├── Pipeline (list of StageDef)
├── DatasetRef (what data to evaluate)
├── Reliability.Config
│   ├── Ensemble (multi-model voting)
│   ├── Hedging (latency optimization)
│   ├── Stats (statistical testing)
│   ├── Fairness (bias detection)
│   └── Guardrails (security)
└── Outputs (list of OutputSpec)
```

## Testing

All modules have comprehensive test coverage:

```bash
mix test
```

Current test stats: **174 tests, 0 failures** (6 doctests + 168 unit tests)

New in v0.1.1:
- 41 validation tests
- 26 serialization tests
- 29 builder tests
- 3 new doctests

## Documentation

Generate HTML documentation:

```bash
mix docs
```

## Integration with Crucible Ecosystem

CrucibleIR is used by:

- **crucible_harness** - Experiment orchestration
- **crucible_ensemble** - Ensemble voting implementation
- **crucible_hedging** - Request hedging implementation
- **crucible_bench** - Statistical testing
- **crucible_telemetry** - Metrics and instrumentation
- **crucible_trace** - Causal transparency

## Design Principles

1. **Immutable Data Structures**: All structs are immutable
2. **Type Safety**: Full type specifications with `@type` and `@spec`
3. **JSON-First**: All structs support JSON serialization
4. **Documentation**: Every module and public function is documented
5. **Test Coverage**: High test coverage with property-based testing

## Contributing

This library is part of the North-Shore-AI organization. Contributions welcome!

## License

MIT License - See LICENSE file for details

## Links

- **GitHub**: https://github.com/North-Shore-AI/crucible_ir
- **Documentation**: https://hexdocs.pm/crucible_ir
- **Crucible Framework**: https://github.com/North-Shore-AI/crucible_framework
