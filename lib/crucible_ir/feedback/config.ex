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
