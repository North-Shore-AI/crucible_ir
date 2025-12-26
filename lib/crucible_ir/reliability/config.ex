defmodule CrucibleIR.Reliability.Config do
  @moduledoc """
  Container for all reliability configurations.

  The `ReliabilityConfig` holds configurations for various reliability
  mechanisms including ensemble voting, hedging, statistical testing,
  fairness checking, and guardrails.

  ## Fields

  - `:ensemble` - Ensemble voting configuration
  - `:hedging` - Request hedging configuration
  - `:guardrails` - Security guardrails configuration
  - `:stats` - Statistical testing configuration
  - `:fairness` - Fairness checking configuration
  - `:monitoring` - Runtime monitoring configuration
  - `:drift` - Drift detection configuration
  - `:circuit_breaker` - Circuit breaker configuration
  - `:feedback` - Feedback collection configuration

  ## Examples

      iex> config = %CrucibleIR.Reliability.Config{
      ...>   ensemble: %CrucibleIR.Reliability.Ensemble{strategy: :majority},
      ...>   stats: %CrucibleIR.Reliability.Stats{alpha: 0.01}
      ...> }
      iex> config.ensemble.strategy
      :majority
  """

  alias CrucibleIR.Reliability.{Ensemble, Hedging, Guardrail, Stats, Fairness}
  alias CrucibleIR.Feedback

  @derive Jason.Encoder
  defstruct ensemble: nil,
            hedging: nil,
            guardrails: nil,
            stats: nil,
            fairness: nil,
            monitoring: nil,
            drift: nil,
            circuit_breaker: nil,
            feedback: nil

  @type t :: %__MODULE__{
          ensemble: Ensemble.t() | nil,
          hedging: Hedging.t() | nil,
          guardrails: Guardrail.t() | nil,
          stats: Stats.t() | nil,
          fairness: Fairness.t() | nil,
          monitoring: map() | nil,
          drift: map() | nil,
          circuit_breaker: map() | nil,
          feedback: Feedback.Config.t() | nil
        }
end
