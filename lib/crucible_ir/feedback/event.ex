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
