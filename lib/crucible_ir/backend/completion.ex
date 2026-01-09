defmodule CrucibleIR.Backend.Completion do
  @moduledoc """
  Universal completion IR for backend responses.

  Normalizes completion outputs across providers (OpenAI, Anthropic, local, etc.)
  while preserving provider-specific data in `raw_response` and `metadata`.

  ## Fields

  - `:choices` - Response choices
  - `:model` - Model name used
  - `:usage` - Token usage summary
  - `:latency_ms` - Total latency in milliseconds
  - `:time_to_first_token_ms` - Time to first token in milliseconds
  - `:request_id` - Request correlation ID
  - `:trace_id` - Trace correlation ID
  - `:raw_response` - Provider response payload
  - `:metadata` - Additional metadata
  """

  alias CrucibleIR.Backend.Prompt

  @type finish_reason :: :stop | :length | :tool_calls | :content_filter | :error

  @type thinking :: %{
          content: String.t(),
          tokens: non_neg_integer()
        }

  @type choice :: %{
          index: non_neg_integer(),
          message: Prompt.message(),
          finish_reason: finish_reason(),
          thinking: thinking() | nil
        }

  @type usage :: %{
          prompt_tokens: non_neg_integer(),
          completion_tokens: non_neg_integer(),
          total_tokens: non_neg_integer(),
          thinking_tokens: non_neg_integer() | nil,
          cached_tokens: non_neg_integer() | nil
        }

  @derive Jason.Encoder
  defstruct choices: [],
            model: nil,
            usage: nil,
            latency_ms: nil,
            time_to_first_token_ms: nil,
            request_id: nil,
            trace_id: nil,
            raw_response: nil,
            metadata: %{}

  @type t :: %__MODULE__{
          choices: [choice()],
          model: String.t() | nil,
          usage: usage() | nil,
          latency_ms: non_neg_integer() | nil,
          time_to_first_token_ms: non_neg_integer() | nil,
          request_id: String.t() | nil,
          trace_id: String.t() | nil,
          raw_response: map() | nil,
          metadata: map()
        }
end
