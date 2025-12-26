defmodule CrucibleIR.Reliability.Hedging do
  @moduledoc """
  Configuration for request hedging to reduce tail latency.

  Hedging sends duplicate requests after a delay to reduce the impact
  of slow responses (tail latency).

  ## Fields

  - `:strategy` - The hedging strategy (default: `:off`)
  - `:delay_ms` - Delay before sending hedge request
  - `:percentile` - Percentile to target (for percentile strategy)
  - `:max_hedges` - Maximum number of hedge requests
  - `:budget_percent` - Maximum cost increase allowed
  - `:options` - Additional hedging-specific options

  ## Hedging Strategies

  - `:off` - No hedging
  - `:fixed` - Fixed delay before hedging
  - `:percentile` - Delay based on percentile latency
  - `:adaptive` - Adapt delay based on observed latency
  - `:workload_aware` - Consider workload characteristics
  - `:exponential_backoff` - Adaptive backoff based on success/failure patterns
  """

  @derive Jason.Encoder
  defstruct strategy: :off,
            delay_ms: nil,
            percentile: nil,
            max_hedges: nil,
            budget_percent: nil,
            options: nil

  @type strategy ::
          :off | :fixed | :percentile | :adaptive | :workload_aware | :exponential_backoff

  @type t :: %__MODULE__{
          strategy: strategy(),
          delay_ms: pos_integer() | nil,
          percentile: float() | nil,
          max_hedges: pos_integer() | nil,
          budget_percent: number() | nil,
          options: map() | nil
        }
end
