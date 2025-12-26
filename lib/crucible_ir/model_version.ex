defmodule CrucibleIR.ModelVersion do
  @moduledoc """
  Specific version of a registered model.

  A `ModelVersion` represents a concrete, immutable snapshot of a model
  at a specific point in time, with associated metrics and lineage.

  ## Fields

  - `:id` - Version identifier (required)
  - `:model_id` - Parent model ID (required)
  - `:version` - Semantic version string (required)
  - `:stage` - Deployment stage
  - `:training_run_id` - Reference to training run
  - `:metrics` - Performance metrics
  - `:artifact_uri` - Path to version artifacts
  - `:parent_version` - Parent version for lineage
  - `:description` - Version description
  - `:created_at` - Creation timestamp
  - `:created_by` - Creator identifier
  - `:options` - Additional options

  ## Examples

      iex> version = %CrucibleIR.ModelVersion{
      ...>   id: :v1_0_0,
      ...>   model_id: :gpt2_base,
      ...>   version: "1.0.0",
      ...>   stage: :production
      ...> }
      iex> version.stage
      :production
  """

  @derive Jason.Encoder
  @enforce_keys [:id, :model_id, :version]
  defstruct [
    :id,
    :model_id,
    :version,
    :training_run_id,
    :metrics,
    :artifact_uri,
    :parent_version,
    :description,
    :created_at,
    :created_by,
    stage: :development,
    options: nil
  ]

  @type stage :: :development | :staging | :production | :archived | atom()

  @type t :: %__MODULE__{
          id: atom(),
          model_id: atom() | String.t(),
          version: String.t(),
          stage: stage(),
          training_run_id: atom() | nil,
          metrics: map() | nil,
          artifact_uri: String.t() | nil,
          parent_version: String.t() | nil,
          description: String.t() | nil,
          created_at: DateTime.t() | nil,
          created_by: String.t() | nil,
          options: map() | nil
        }
end
