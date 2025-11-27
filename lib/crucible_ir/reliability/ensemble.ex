defmodule CrucibleIR.Reliability.Ensemble do
  @moduledoc """
  Configuration for ensemble voting strategies.

  Ensemble voting uses multiple models to make predictions and combines
  their outputs using various voting strategies.

  ## Fields

  - `:strategy` - The voting strategy (default: `:none`)
  - `:execution_mode` - How to execute models (default: `:parallel`)
  - `:models` - List of model identifiers to use in the ensemble
  - `:weights` - Model weights for weighted voting
  - `:min_agreement` - Minimum agreement threshold for voting
  - `:timeout_ms` - Timeout for model execution
  - `:options` - Additional ensemble-specific options

  ## Voting Strategies

  - `:none` - No ensemble (single model)
  - `:majority` - Simple majority vote
  - `:weighted` - Weighted vote based on model weights
  - `:best_confidence` - Select output with highest confidence
  - `:unanimous` - Require all models to agree

  ## Execution Modes

  - `:parallel` - Execute all models simultaneously
  - `:sequential` - Execute models one at a time
  - `:hedged` - Use hedging for parallel execution
  - `:cascade` - Stop when threshold is reached
  """

  @derive Jason.Encoder
  defstruct strategy: :none,
            execution_mode: :parallel,
            models: nil,
            weights: nil,
            min_agreement: nil,
            timeout_ms: nil,
            options: nil

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
end
