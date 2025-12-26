defmodule CrucibleIR.Training.Run do
  @moduledoc """
  Represents a training execution.

  A `TrainingRun` tracks the execution of a training configuration,
  including status, metrics, artifacts, and timing information.

  ## Fields

  - `:id` - Run identifier (required)
  - `:config` - Training configuration (required)
  - `:status` - Current run status
  - `:current_epoch` - Current training epoch
  - `:metrics_history` - Metrics over time
  - `:best_metrics` - Best achieved metrics
  - `:checkpoint_uris` - Saved checkpoint paths
  - `:final_model_version` - Resulting model version
  - `:started_at` - Start timestamp
  - `:completed_at` - Completion timestamp
  - `:error_message` - Error if failed
  - `:options` - Additional options

  ## Examples

      iex> config = %CrucibleIR.Training.Config{
      ...>   id: :train_config,
      ...>   model_ref: %CrucibleIR.ModelRef{id: :gpt2},
      ...>   dataset_ref: %CrucibleIR.DatasetRef{name: :wikitext}
      ...> }
      iex> run = %CrucibleIR.Training.Run{
      ...>   id: :run_001,
      ...>   config: config,
      ...>   status: :running
      ...> }
      iex> run.status
      :running
  """

  alias CrucibleIR.Training.Config

  @derive Jason.Encoder
  @enforce_keys [:id, :config]
  defstruct [
    :id,
    :config,
    :current_epoch,
    :metrics_history,
    :best_metrics,
    :checkpoint_uris,
    :final_model_version,
    :started_at,
    :completed_at,
    :error_message,
    status: :pending,
    options: nil
  ]

  @type status :: :pending | :running | :completed | :failed | :cancelled | atom()

  @type t :: %__MODULE__{
          id: atom(),
          config: Config.t(),
          status: status(),
          current_epoch: pos_integer() | nil,
          metrics_history: [map()] | nil,
          best_metrics: map() | nil,
          checkpoint_uris: [String.t()] | nil,
          final_model_version: atom() | nil,
          started_at: DateTime.t() | nil,
          completed_at: DateTime.t() | nil,
          error_message: String.t() | nil,
          options: map() | nil
        }
end
