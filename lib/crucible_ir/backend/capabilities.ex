defmodule CrucibleIR.Backend.Capabilities do
  @moduledoc """
  Declares backend capabilities and limits.

  This struct is used for capability discovery, routing, and cost visibility.

  ## Fields

  - `:backend_id` - Backend identifier
  - `:provider` - Provider name
  - `:models` - Supported models
  - `:default_model` - Default model
  - `:supports_streaming` - Streaming support
  - `:supports_tools` - Tool calling support
  - `:supports_vision` - Vision support
  - `:supports_audio` - Audio support
  - `:supports_json_mode` - JSON mode support
  - `:supports_extended_thinking` - Extended thinking support
  - `:supports_caching` - Caching support
  - `:max_tokens` - Maximum completion tokens
  - `:max_context_length` - Maximum context length
  - `:max_images_per_request` - Maximum images per request
  - `:requests_per_minute` - RPM limit
  - `:tokens_per_minute` - TPM limit
  - `:cost_per_million_input` - Input token cost (per 1M)
  - `:cost_per_million_output` - Output token cost (per 1M)
  - `:metadata` - Additional metadata
  """

  @derive Jason.Encoder
  @enforce_keys [:backend_id, :provider]
  defstruct [
    :backend_id,
    :provider,
    models: [],
    default_model: nil,
    supports_streaming: true,
    supports_tools: true,
    supports_vision: false,
    supports_audio: false,
    supports_json_mode: true,
    supports_extended_thinking: false,
    supports_caching: false,
    max_tokens: nil,
    max_context_length: nil,
    max_images_per_request: nil,
    requests_per_minute: nil,
    tokens_per_minute: nil,
    cost_per_million_input: nil,
    cost_per_million_output: nil,
    metadata: %{}
  ]

  @type t :: %__MODULE__{
          backend_id: atom(),
          provider: String.t(),
          models: [String.t()],
          default_model: String.t() | nil,
          supports_streaming: boolean(),
          supports_tools: boolean(),
          supports_vision: boolean(),
          supports_audio: boolean(),
          supports_json_mode: boolean(),
          supports_extended_thinking: boolean(),
          supports_caching: boolean(),
          max_tokens: non_neg_integer() | nil,
          max_context_length: non_neg_integer() | nil,
          max_images_per_request: non_neg_integer() | nil,
          requests_per_minute: non_neg_integer() | nil,
          tokens_per_minute: non_neg_integer() | nil,
          cost_per_million_input: float() | nil,
          cost_per_million_output: float() | nil,
          metadata: map()
        }
end
