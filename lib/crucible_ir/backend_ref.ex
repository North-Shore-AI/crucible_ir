defmodule CrucibleIR.BackendRef do
  @moduledoc """
  Reference to an LLM backend to be used in an experiment.

  A `BackendRef` identifies a specific LLM backend (like GPT-4 or Claude),
  with an optional configuration profile and additional options.

  ## Fields

  - `:id` - The backend identifier (required)
  - `:profile` - The configuration profile to use (default: `:default`)
  - `:options` - Additional backend-specific options
  - `:model_version` - Specific model version string
  - `:endpoint_url` - Custom endpoint URL
  - `:deployment_id` - Link to deployment
  - `:fallback` - Fallback backend reference

  ## Examples

      iex> ref = %CrucibleIR.BackendRef{id: :openai_gpt4}
      iex> ref.profile
      :default

      iex> ref = %CrucibleIR.BackendRef{id: :anthropic_claude, profile: :fast}
      iex> ref.profile
      :fast

      iex> ref = %CrucibleIR.BackendRef{id: :openai_gpt4, options: %{temperature: 0.7}}
      iex> ref.options
      %{temperature: 0.7}
  """

  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :model_version,
    :endpoint_url,
    :deployment_id,
    :fallback,
    profile: :default,
    options: nil
  ]

  @type t :: %__MODULE__{
          id: atom(),
          profile: atom(),
          options: map() | nil,
          model_version: String.t() | nil,
          endpoint_url: String.t() | nil,
          deployment_id: atom() | nil,
          fallback: t() | nil
        }
end
