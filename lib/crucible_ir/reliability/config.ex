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

  ## Examples

      iex> config = %CrucibleIR.Reliability.Config{
      ...>   ensemble: %CrucibleIR.Reliability.Ensemble{strategy: :majority},
      ...>   stats: %CrucibleIR.Reliability.Stats{alpha: 0.01}
      ...> }
      iex> config.ensemble.strategy
      :majority
  """

  alias CrucibleIR.Reliability.{Ensemble, Hedging, Guardrail, Stats, Fairness}

  @derive Jason.Encoder
  defstruct ensemble: nil,
            hedging: nil,
            guardrails: nil,
            stats: nil,
            fairness: nil

  @type t :: %__MODULE__{
          ensemble: Ensemble.t() | nil,
          hedging: Hedging.t() | nil,
          guardrails: Guardrail.t() | nil,
          stats: Stats.t() | nil,
          fairness: Fairness.t() | nil
        }
end
