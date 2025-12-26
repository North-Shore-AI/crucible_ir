defmodule CrucibleIR.ModelRef do
  @moduledoc """
  Reference to a registered model in the model registry.

  A `ModelRef` identifies a specific model that can be used for training,
  evaluation, or deployment. It supports multiple providers and frameworks.

  ## Fields

  - `:id` - Model identifier (required)
  - `:name` - Human-readable model name
  - `:version` - Semantic version string
  - `:provider` - Model source/provider
  - `:framework` - ML framework
  - `:architecture` - Model architecture type
  - `:task` - ML task type
  - `:artifact_uri` - Path to model artifacts
  - `:metadata` - Additional metadata
  - `:options` - Provider-specific options

  ## Examples

      iex> ref = %CrucibleIR.ModelRef{id: :gpt2_base, provider: :huggingface}
      iex> ref.provider
      :huggingface
  """

  @derive Jason.Encoder
  @enforce_keys [:id]
  defstruct [
    :id,
    :name,
    :version,
    :artifact_uri,
    :architecture,
    :task,
    :metadata,
    provider: :local,
    framework: :nx,
    options: nil
  ]

  @type provider :: :local | :huggingface | :openai | :anthropic | :s3 | :gcs | atom()
  @type framework :: :nx | :pytorch | :tensorflow | :onnx | :safetensors | atom()
  @type task ::
          :text_classification | :text_generation | :embedding | :qa | :summarization | atom()
  @type architecture :: :transformer | :lstm | :cnn | :mlp | atom()

  @type t :: %__MODULE__{
          id: atom() | String.t(),
          name: String.t() | nil,
          version: String.t() | nil,
          provider: provider(),
          framework: framework(),
          architecture: architecture() | nil,
          task: task() | nil,
          artifact_uri: String.t() | nil,
          metadata: map() | nil,
          options: map() | nil
        }
end
