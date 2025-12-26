defmodule CrucibleIR.Deployment.Config do
  @moduledoc """
  Configuration for model deployment.

  Defines where and how a model version should be deployed,
  including resource requirements and scaling settings.

  ## Fields

  - `:id` - Deployment identifier (required)
  - `:model_version_id` - Model version to deploy (required)
  - `:target` - Deployment target configuration
  - `:replicas` - Number of replicas
  - `:resources` - Resource requirements
  - `:scaling` - Auto-scaling configuration
  - `:environment` - Target environment
  - `:strategy` - Deployment strategy
  - `:health_check` - Health check settings
  - `:endpoint` - API endpoint configuration
  - `:metadata` - Additional metadata
  - `:options` - Additional options

  ## Examples

      iex> config = %CrucibleIR.Deployment.Config{
      ...>   id: :deploy_prod,
      ...>   model_version_id: :v1_0_0,
      ...>   environment: :production
      ...> }
      iex> config.environment
      :production
  """

  @derive Jason.Encoder
  @enforce_keys [:id, :model_version_id]
  defstruct [
    :id,
    :model_version_id,
    :target,
    :resources,
    :scaling,
    :health_check,
    :endpoint,
    :metadata,
    replicas: 1,
    environment: :development,
    strategy: :rolling,
    options: nil
  ]

  @type environment :: :development | :staging | :production | atom()
  @type strategy :: :rolling | :blue_green | :canary | :recreate | atom()

  @type t :: %__MODULE__{
          id: atom(),
          model_version_id: atom(),
          target: map() | nil,
          replicas: pos_integer(),
          resources: map() | nil,
          scaling: map() | nil,
          environment: environment(),
          strategy: strategy(),
          health_check: map() | nil,
          endpoint: map() | nil,
          metadata: map() | nil,
          options: map() | nil
        }
end
