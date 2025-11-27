defmodule CrucibleIR.Experiment do
  @moduledoc """
  Top-level experiment definition for Crucible ML reliability experiments.

  An `Experiment` defines a complete ML reliability experiment including
  the backend to test, the evaluation pipeline, datasets, reliability
  mechanisms, and output specifications.

  ## Required Fields

  - `:id` - Unique experiment identifier
  - `:backend` - The LLM backend to evaluate (BackendRef)
  - `:pipeline` - List of processing stages (StageDef)

  ## Optional Fields

  - `:description` - Human-readable experiment description
  - `:owner` - Experiment owner/creator
  - `:tags` - List of tags for categorization
  - `:metadata` - Additional experiment metadata
  - `:dataset` - Dataset reference for evaluation
  - `:reliability` - Reliability configurations (ensemble, hedging, etc.)
  - `:outputs` - Output specifications
  - `:created_at` - Experiment creation timestamp
  - `:updated_at` - Last update timestamp

  ## Examples

      iex> exp = %CrucibleIR.Experiment{
      ...>   id: :my_experiment,
      ...>   backend: %CrucibleIR.BackendRef{id: :gpt4},
      ...>   pipeline: [%CrucibleIR.StageDef{name: :inference}]
      ...> }
      iex> exp.id
      :my_experiment

      iex> exp = %CrucibleIR.Experiment{
      ...>   id: :full_exp,
      ...>   backend: %CrucibleIR.BackendRef{id: :gpt4},
      ...>   pipeline: [%CrucibleIR.StageDef{name: :run}],
      ...>   dataset: %CrucibleIR.DatasetRef{name: :mmlu},
      ...>   reliability: %CrucibleIR.Reliability.Config{
      ...>     stats: %CrucibleIR.Reliability.Stats{alpha: 0.01}
      ...>   }
      ...> }
      iex> exp.reliability.stats.alpha
      0.01
  """

  alias CrucibleIR.{BackendRef, DatasetRef, StageDef, OutputSpec}
  alias CrucibleIR.Reliability.Config

  @derive Jason.Encoder
  @enforce_keys [:id, :backend, :pipeline]
  defstruct [
    :id,
    :backend,
    :pipeline,
    :description,
    :owner,
    :tags,
    :metadata,
    :dataset,
    :reliability,
    :outputs,
    :created_at,
    :updated_at
  ]

  @type t :: %__MODULE__{
          id: atom(),
          backend: BackendRef.t(),
          pipeline: [StageDef.t()],
          description: String.t() | nil,
          owner: String.t() | nil,
          tags: [atom()] | nil,
          metadata: map() | nil,
          dataset: DatasetRef.t() | nil,
          reliability: Config.t() | nil,
          outputs: [OutputSpec.t()] | nil,
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }
end
