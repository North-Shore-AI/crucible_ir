defmodule CrucibleIR.Deployment.Status do
  @moduledoc """
  Status of an active deployment.

  Tracks the current state of a deployment including health,
  traffic routing, and replica status.

  ## Fields

  - `:id` - Status identifier (required)
  - `:deployment_id` - Associated deployment (required)
  - `:state` - Current deployment state
  - `:ready_replicas` - Number of ready replicas
  - `:total_replicas` - Total number of replicas
  - `:endpoint_url` - Active endpoint URL
  - `:traffic_percent` - Percentage of traffic
  - `:health` - Health status
  - `:last_health_check` - Last health check timestamp
  - `:error_message` - Error if unhealthy
  - `:created_at` - Creation timestamp
  - `:updated_at` - Last update timestamp

  ## Examples

      iex> status = %CrucibleIR.Deployment.Status{
      ...>   id: :status_001,
      ...>   deployment_id: :deploy_prod,
      ...>   state: :active
      ...> }
      iex> status.state
      :active
  """

  @derive Jason.Encoder
  @enforce_keys [:id, :deployment_id]
  defstruct [
    :id,
    :deployment_id,
    :ready_replicas,
    :total_replicas,
    :endpoint_url,
    :traffic_percent,
    :last_health_check,
    :error_message,
    :created_at,
    :updated_at,
    state: :pending,
    health: :unknown
  ]

  @type state :: :pending | :deploying | :active | :degraded | :failed | :terminated | atom()
  @type health :: :unknown | :healthy | :unhealthy | :degraded | atom()

  @type t :: %__MODULE__{
          id: atom(),
          deployment_id: atom(),
          state: state(),
          ready_replicas: pos_integer() | nil,
          total_replicas: pos_integer() | nil,
          endpoint_url: String.t() | nil,
          traffic_percent: float() | nil,
          health: health(),
          last_health_check: DateTime.t() | nil,
          error_message: String.t() | nil,
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }
end
