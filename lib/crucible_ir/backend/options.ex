defmodule CrucibleIR.Backend.Options do
  @moduledoc """
  Generation options for backend requests.

  These options normalize common LLM parameters across providers while keeping
  a safe escape hatch via `extra` for provider-specific settings.

  ## Fields

  - `:model` - Model name or ID
  - `:temperature` - Sampling temperature
  - `:max_tokens` - Maximum tokens to generate
  - `:top_p` - Nucleus sampling probability
  - `:top_k` - Top-k sampling
  - `:frequency_penalty` - Penalize frequent tokens
  - `:presence_penalty` - Penalize repeated tokens
  - `:stop` - Stop sequences
  - `:response_format` - Response format (`:text`, `:json`, `:json_schema`)
  - `:json_schema` - JSON schema for structured output
  - `:stream` - Whether to stream responses
  - `:cache_control` - Caching policy (`:ephemeral`)
  - `:extended_thinking` - Enable extended reasoning (provider-specific)
  - `:thinking_budget_tokens` - Token budget for extended thinking
  - `:seed` - Random seed for reproducibility
  - `:timeout_ms` - Request timeout in milliseconds
  - `:extra` - Provider-specific options

  ## Examples

      iex> %CrucibleIR.Backend.Options{model: "gpt-4o", temperature: 0.2}
  """

  @derive Jason.Encoder
  defstruct [
    :model,
    :temperature,
    :max_tokens,
    :top_p,
    :top_k,
    :frequency_penalty,
    :presence_penalty,
    :stop,
    :response_format,
    :json_schema,
    stream: false,
    cache_control: nil,
    extended_thinking: false,
    thinking_budget_tokens: nil,
    seed: nil,
    timeout_ms: nil,
    extra: %{}
  ]

  @type response_format :: :text | :json | :json_schema | atom()
  @type cache_control :: :ephemeral | atom()

  @type t :: %__MODULE__{
          model: String.t() | nil,
          temperature: float() | nil,
          max_tokens: non_neg_integer() | nil,
          top_p: float() | nil,
          top_k: non_neg_integer() | nil,
          frequency_penalty: float() | nil,
          presence_penalty: float() | nil,
          stop: [String.t()] | nil,
          response_format: response_format() | nil,
          json_schema: map() | nil,
          stream: boolean(),
          cache_control: cache_control() | nil,
          extended_thinking: boolean(),
          thinking_budget_tokens: non_neg_integer() | nil,
          seed: integer() | nil,
          timeout_ms: non_neg_integer() | nil,
          extra: map()
        }
end
