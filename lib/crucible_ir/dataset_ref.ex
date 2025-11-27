defmodule CrucibleIR.DatasetRef do
  @moduledoc """
  Reference to a dataset to be used in an experiment.

  A `DatasetRef` points to a dataset from a specific provider (like `crucible_datasets`),
  with a specific split (like `:train` or `:test`), and optional configuration.

  ## Fields

  - `:provider` - The dataset provider (default: `:crucible_datasets`)
  - `:name` - The dataset name (required)
  - `:split` - The dataset split to use (default: `:train`)
  - `:options` - Additional dataset-specific options

  ## Examples

      iex> ref = %CrucibleIR.DatasetRef{name: :mmlu}
      iex> ref.provider
      :crucible_datasets

      iex> ref = %CrucibleIR.DatasetRef{name: :mmlu, split: :test}
      iex> ref.split
      :test

      iex> ref = %CrucibleIR.DatasetRef{name: :custom, provider: :huggingface, options: %{limit: 100}}
      iex> ref.options
      %{limit: 100}
  """

  @derive Jason.Encoder
  @enforce_keys [:name]
  defstruct [
    :name,
    provider: :crucible_datasets,
    split: :train,
    options: nil
  ]

  @type provider :: :crucible_datasets | :huggingface | atom()
  @type split :: :train | :test | :validation | atom()

  @type t :: %__MODULE__{
          provider: provider(),
          name: atom(),
          split: split(),
          options: map() | nil
        }
end
