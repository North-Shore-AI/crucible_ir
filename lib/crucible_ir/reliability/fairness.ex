defmodule CrucibleIR.Reliability.Fairness do
  @moduledoc """
  Configuration for fairness and bias detection.

  Controls fairness metrics, group definitions, and violation handling.

  ## Fields

  - `:enabled` - Whether fairness checking is enabled (default: `false`)
  - `:metrics` - List of fairness metrics to compute
  - `:group_by` - Attribute to group by for fairness analysis
  - `:threshold` - Fairness threshold (e.g., 0.8 for 80% rule)
  - `:fail_on_violation` - Whether to fail when violations detected
  - `:options` - Additional fairness options

  ## Available Metrics

  - `:demographic_parity` - Equal positive prediction rates
  - `:equalized_odds` - Equal TPR and FPR across groups
  - `:equal_opportunity` - Equal TPR for qualified candidates
  - `:predictive_parity` - Equal positive predictive values
  """

  @derive Jason.Encoder
  defstruct enabled: false,
            metrics: nil,
            group_by: nil,
            threshold: nil,
            fail_on_violation: nil,
            options: nil

  @type metric ::
          :demographic_parity
          | :equalized_odds
          | :equal_opportunity
          | :predictive_parity
          | atom()

  @type t :: %__MODULE__{
          enabled: boolean(),
          metrics: [metric()] | nil,
          group_by: atom() | nil,
          threshold: float() | nil,
          fail_on_violation: boolean() | nil,
          options: map() | nil
        }
end
