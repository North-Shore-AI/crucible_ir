defmodule CrucibleIR.Training.Config do
  @moduledoc """
  Configuration for model training.

  Defines hyperparameters, optimizer settings, and training options
  for a training run.

  ## Fields

  - `:id` - Config identifier (required)
  - `:model_ref` - Reference to model to train (required)
  - `:dataset_ref` - Training dataset (required)
  - `:epochs` - Number of training epochs
  - `:batch_size` - Batch size
  - `:learning_rate` - Initial learning rate
  - `:optimizer` - Optimizer type
  - `:loss_function` - Loss function
  - `:metrics` - Metrics to track
  - `:validation_split` - Validation data ratio
  - `:device` - Compute device
  - `:seed` - Random seed
  - `:mixed_precision` - Use mixed precision
  - `:gradient_clipping` - Max gradient norm
  - `:early_stopping` - Early stopping config
  - `:checkpoint_every` - Checkpoint frequency
  - `:options` - Additional options

  ## Examples

      iex> config = %CrucibleIR.Training.Config{
      ...>   id: :train_gpt2,
      ...>   model_ref: %CrucibleIR.ModelRef{id: :gpt2},
      ...>   dataset_ref: %CrucibleIR.DatasetRef{name: :wikitext},
      ...>   epochs: 10,
      ...>   batch_size: 32
      ...> }
      iex> config.epochs
      10
  """

  alias CrucibleIR.{ModelRef, DatasetRef}

  @derive Jason.Encoder
  @enforce_keys [:id, :model_ref, :dataset_ref]
  defstruct [
    :id,
    :model_ref,
    :dataset_ref,
    :validation_split,
    :seed,
    :gradient_clipping,
    :early_stopping,
    :checkpoint_every,
    epochs: 1,
    batch_size: 32,
    learning_rate: 0.001,
    optimizer: :adam,
    loss_function: :cross_entropy,
    metrics: [:loss, :accuracy],
    device: :cpu,
    mixed_precision: false,
    options: nil
  ]

  @type optimizer :: :adam | :sgd | :adamw | :rmsprop | atom()
  @type loss :: :cross_entropy | :mse | :mae | :bce | atom()
  @type device :: :cpu | :cuda | :mps | :tpu | atom()

  @type t :: %__MODULE__{
          id: atom(),
          model_ref: ModelRef.t(),
          dataset_ref: DatasetRef.t(),
          epochs: pos_integer(),
          batch_size: pos_integer(),
          learning_rate: float(),
          optimizer: optimizer(),
          loss_function: loss(),
          metrics: [atom()],
          validation_split: float() | nil,
          device: device(),
          seed: integer() | nil,
          mixed_precision: boolean(),
          gradient_clipping: float() | nil,
          early_stopping: map() | nil,
          checkpoint_every: pos_integer() | nil,
          options: map() | nil
        }
end
