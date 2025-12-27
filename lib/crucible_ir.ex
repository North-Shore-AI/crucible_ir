defmodule CrucibleIR do
  @moduledoc """
  Intermediate Representation for the Crucible ML reliability ecosystem.

  `CrucibleIR` provides shared data structures for defining ML reliability
  experiments across the Crucible ecosystem. It includes definitions for
  experiments, backends, datasets, reliability configurations, and more.

  This package is data-only: structs, serialization, and structural validation.
  Execution logic and stage option validation belong in domain packages.

  ## Main Components

  - `CrucibleIR.Experiment` - Top-level experiment definition
  - `CrucibleIR.BackendRef` - Reference to an LLM backend
  - `CrucibleIR.DatasetRef` - Reference to a dataset
  - `CrucibleIR.StageDef` - Processing stage definition
  - `CrucibleIR.OutputSpec` - Output specification
  - `CrucibleIR.Reliability.Config` - Container for reliability configurations

  ## Model Lifecycle (v0.2.0)

  - `CrucibleIR.ModelRef` - Reference to a registered model
  - `CrucibleIR.ModelVersion` - Specific model version
  - `CrucibleIR.Training.Config` - Training configuration
  - `CrucibleIR.Training.Run` - Training execution record
  - `CrucibleIR.Deployment.Config` - Deployment configuration
  - `CrucibleIR.Deployment.Status` - Deployment status
  - `CrucibleIR.Feedback.Event` - Feedback data point
  - `CrucibleIR.Feedback.Config` - Feedback collection configuration

  ## Reliability Mechanisms

  - `CrucibleIR.Reliability.Ensemble` - Ensemble voting configuration
  - `CrucibleIR.Reliability.Hedging` - Request hedging configuration
  - `CrucibleIR.Reliability.Stats` - Statistical testing configuration
  - `CrucibleIR.Reliability.Fairness` - Fairness checking configuration
  - `CrucibleIR.Reliability.Guardrail` - Security guardrails configuration

  ## Example

      iex> alias CrucibleIR.{Experiment, BackendRef, StageDef}
      iex> exp = CrucibleIR.new_experiment(
      ...>   id: :my_exp,
      ...>   backend: %BackendRef{id: :gpt4},
      ...>   pipeline: [%StageDef{name: :inference}]
      ...> )
      iex> exp.backend.id
      :gpt4
  """

  alias CrucibleIR.Experiment

  @doc """
  Creates a new experiment with the given attributes.

  This is a convenience function for creating `CrucibleIR.Experiment` structs.

  ## Parameters

  - `attrs` - Keyword list of experiment attributes

  ## Required Attributes

  - `:id` - Unique experiment identifier
  - `:backend` - BackendRef struct
  - `:pipeline` - List of StageDef structs

  ## Optional Attributes

  - `:description` - Experiment description
  - `:owner` - Experiment owner
  - `:tags` - List of tags
  - `:metadata` - Additional metadata map
  - `:dataset` - DatasetRef struct
  - `:reliability` - Reliability.Config struct
  - `:outputs` - List of OutputSpec structs
  - `:created_at` - Creation timestamp
  - `:updated_at` - Update timestamp

  ## Examples

      iex> alias CrucibleIR.{BackendRef, StageDef}
      iex> exp = CrucibleIR.new_experiment(
      ...>   id: :test,
      ...>   backend: %BackendRef{id: :gpt4},
      ...>   pipeline: [%StageDef{name: :run}]
      ...> )
      iex> exp.id
      :test

      iex> alias CrucibleIR.{BackendRef, StageDef, DatasetRef}
      iex> alias CrucibleIR.Reliability.{Config, Stats}
      iex> exp = CrucibleIR.new_experiment(
      ...>   id: :exp1,
      ...>   backend: %BackendRef{id: :gpt4},
      ...>   pipeline: [%StageDef{name: :run}],
      ...>   dataset: %DatasetRef{name: :mmlu},
      ...>   reliability: %Config{stats: %Stats{alpha: 0.01}}
      ...> )
      iex> exp.reliability.stats.alpha
      0.01
  """
  @spec new_experiment(keyword()) :: Experiment.t()
  def new_experiment(attrs) when is_list(attrs) do
    struct!(Experiment, attrs)
  end

  # Validation functions

  @doc """
  Validates a struct, returns `{:ok, struct}` or `{:error, errors}`.

  Delegates to `CrucibleIR.Validation.validate/1`.

  ## Examples

      iex> alias CrucibleIR.{Experiment, BackendRef, StageDef}
      iex> exp = %Experiment{
      ...>   id: :test,
      ...>   backend: %BackendRef{id: :gpt4},
      ...>   pipeline: [%StageDef{name: :run}]
      ...> }
      iex> {:ok, _} = CrucibleIR.validate(exp)
  """
  defdelegate validate(struct), to: CrucibleIR.Validation

  @doc """
  Returns `true` if struct is valid, `false` otherwise.

  Delegates to `CrucibleIR.Validation.valid?/1`.

  ## Examples

      iex> alias CrucibleIR.BackendRef
      iex> CrucibleIR.valid?(%BackendRef{id: :gpt4})
      true
  """
  defdelegate valid?(struct), to: CrucibleIR.Validation

  # Serialization functions

  @doc """
  Encodes a struct to JSON string.

  Delegates to `CrucibleIR.Serialization.to_json/1`.

  ## Examples

      iex> alias CrucibleIR.BackendRef
      iex> json = CrucibleIR.to_json(%BackendRef{id: :gpt4})
      iex> is_binary(json)
      true
  """
  defdelegate to_json(struct), to: CrucibleIR.Serialization

  @doc """
  Decodes JSON string to struct of given type.

  Delegates to `CrucibleIR.Serialization.from_json/2`.

  ## Examples

      iex> alias CrucibleIR.BackendRef
      iex> json = ~s({"id":"gpt4","profile":"default"})
      iex> {:ok, backend} = CrucibleIR.from_json(json, BackendRef)
      iex> backend.id
      :gpt4
  """
  defdelegate from_json(json, type), to: CrucibleIR.Serialization

  @doc """
  Converts a map to struct of given type.

  Delegates to `CrucibleIR.Serialization.from_map/2`.

  ## Examples

      iex> alias CrucibleIR.BackendRef
      iex> {:ok, backend} = CrucibleIR.from_map(%{"id" => "gpt4"}, BackendRef)
      iex> backend.id
      :gpt4
  """
  defdelegate from_map(map, type), to: CrucibleIR.Serialization

  # Builder convenience

  @doc """
  Creates a new experiment builder with the given ID.

  Delegates to `CrucibleIR.Builder.experiment/1`.

  ## Examples

      iex> exp = CrucibleIR.experiment(:test)
      iex> exp.id
      :test
  """
  defdelegate experiment(id), to: CrucibleIR.Builder
end
