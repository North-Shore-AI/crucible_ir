defmodule CrucibleIR.Validation do
  @moduledoc """
  Validation helpers for IR structs.

  This module provides functions to validate CrucibleIR data structures
  and ensure they meet the required constraints before being used in
  experiments.

  ## Functions

  - `validate/1` - Validates a struct, returns `{:ok, struct}` or `{:error, errors}`
  - `valid?/1` - Returns `true` if struct is valid, `false` otherwise
  - `errors/1` - Returns list of validation errors

  Validation here is structural only. Stage option validation and execution
  semantics belong to domain packages, not CrucibleIR.

  ## Examples

      iex> alias CrucibleIR.{Experiment, BackendRef, StageDef}
      iex> exp = %Experiment{
      ...>   id: :test,
      ...>   backend: %BackendRef{id: :gpt4},
      ...>   pipeline: [%StageDef{name: :run}]
      ...> }
      iex> CrucibleIR.Validation.valid?(exp)
      true

      iex> alias CrucibleIR.BackendRef
      iex> backend = %BackendRef{id: nil}
      iex> {:error, errors} = CrucibleIR.Validation.validate(backend)
      iex> "id must be a non-nil atom" in errors
      true
  """

  alias CrucibleIR.Deployment
  alias CrucibleIR.Feedback

  alias CrucibleIR.{
    BackendRef,
    DatasetRef,
    Experiment,
    ModelRef,
    ModelVersion,
    OutputSpec,
    StageDef
  }

  alias CrucibleIR.Reliability.{Config, Ensemble, Fairness, Guardrail, Hedging, Stats}
  alias CrucibleIR.Training

  @doc """
  Validates a struct and returns `{:ok, struct}` if valid or `{:error, errors}` if invalid.

  ## Parameters

  - `struct` - Any CrucibleIR struct to validate

  ## Returns

  - `{:ok, struct}` - If the struct is valid
  - `{:error, [error_message]}` - If the struct has validation errors

  ## Examples

      iex> alias CrucibleIR.BackendRef
      iex> backend = %BackendRef{id: :gpt4}
      iex> {:ok, ^backend} = CrucibleIR.Validation.validate(backend)
      {:ok, %CrucibleIR.BackendRef{id: :gpt4}}

      iex> alias CrucibleIR.BackendRef
      iex> backend = %BackendRef{id: nil}
      iex> {:error, _errors} = CrucibleIR.Validation.validate(backend)
  """
  @spec validate(struct()) :: {:ok, struct()} | {:error, [String.t()]}
  def validate(%Experiment{} = exp), do: validate_experiment(exp)
  def validate(%BackendRef{} = backend), do: validate_backend_ref(backend)
  def validate(%StageDef{} = stage), do: validate_stage_def(stage)
  def validate(%DatasetRef{} = dataset), do: validate_dataset_ref(dataset)
  def validate(%OutputSpec{} = output), do: validate_output_spec(output)
  def validate(%Config{} = config), do: validate_reliability_config(config)
  def validate(%Ensemble{} = ensemble), do: validate_ensemble(ensemble)
  def validate(%Hedging{} = hedging), do: validate_hedging(hedging)
  def validate(%Stats{} = stats), do: validate_stats(stats)
  def validate(%Fairness{} = fairness), do: validate_fairness(fairness)
  def validate(%Guardrail{} = guardrail), do: validate_guardrail(guardrail)
  def validate(%ModelRef{} = model), do: validate_model_ref(model)
  def validate(%ModelVersion{} = version), do: validate_model_version(version)
  def validate(%Training.Config{} = config), do: validate_training_config(config)
  def validate(%Training.Run{} = run), do: validate_training_run(run)
  def validate(%Deployment.Config{} = config), do: validate_deployment_config(config)
  def validate(%Deployment.Status{} = status), do: validate_deployment_status(status)
  def validate(%Feedback.Event{} = event), do: validate_feedback_event(event)
  def validate(%Feedback.Config{} = config), do: validate_feedback_config(config)

  @doc """
  Returns `true` if the struct is valid, `false` otherwise.

  ## Parameters

  - `struct` - Any CrucibleIR struct to check

  ## Examples

      iex> alias CrucibleIR.BackendRef
      iex> backend = %BackendRef{id: :gpt4}
      iex> CrucibleIR.Validation.valid?(backend)
      true

      iex> alias CrucibleIR.BackendRef
      iex> backend = %BackendRef{id: nil}
      iex> CrucibleIR.Validation.valid?(backend)
      false
  """
  @spec valid?(struct()) :: boolean()
  def valid?(struct) do
    case validate(struct) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  @doc """
  Returns a list of validation errors for the struct.

  Returns an empty list if the struct is valid.

  ## Parameters

  - `struct` - Any CrucibleIR struct to check

  ## Examples

      iex> alias CrucibleIR.BackendRef
      iex> backend = %BackendRef{id: :gpt4}
      iex> CrucibleIR.Validation.errors(backend)
      []

      iex> alias CrucibleIR.BackendRef
      iex> backend = %BackendRef{id: nil}
      iex> errors = CrucibleIR.Validation.errors(backend)
      iex> length(errors) > 0
      true
  """
  @spec errors(struct()) :: [String.t()]
  def errors(struct) do
    case validate(struct) do
      {:ok, _} -> []
      {:error, errors} -> errors
    end
  end

  # Private validation functions

  defp validate_experiment(%Experiment{} = exp) do
    []
    |> validate_experiment_id(exp)
    |> validate_experiment_backend(exp)
    |> validate_experiment_pipeline(exp)
    |> validate_experiment_reliability(exp)
    |> finalize_validation(exp)
  end

  defp validate_experiment_id(errors, %Experiment{id: id}) do
    if is_nil(id) or id == :"" do
      ["id must be non-empty atom" | errors]
    else
      errors
    end
  end

  defp validate_experiment_backend(errors, %Experiment{backend: nil}) do
    ["backend is required" | errors]
  end

  defp validate_experiment_backend(errors, %Experiment{backend: backend}) do
    case validate(backend) do
      {:ok, _} -> errors
      {:error, backend_errors} -> Enum.map(backend_errors, &"backend.#{&1}") ++ errors
    end
  end

  defp validate_experiment_pipeline(errors, %Experiment{pipeline: nil}) do
    ["pipeline must be a list" | errors]
  end

  defp validate_experiment_pipeline(errors, %Experiment{pipeline: pipeline})
       when not is_list(pipeline) do
    ["pipeline must be a list" | errors]
  end

  defp validate_experiment_pipeline(errors, %Experiment{pipeline: []}) do
    ["pipeline must contain at least one stage" | errors]
  end

  defp validate_experiment_pipeline(errors, %Experiment{pipeline: pipeline}) do
    Enum.reduce(pipeline, errors, fn stage, acc ->
      case validate(stage) do
        {:ok, _} -> acc
        {:error, stage_errors} -> Enum.map(stage_errors, &"pipeline stage #{&1}") ++ acc
      end
    end)
  end

  defp validate_experiment_reliability(errors, %Experiment{reliability: nil}) do
    errors
  end

  defp validate_experiment_reliability(errors, %Experiment{reliability: reliability}) do
    case validate(reliability) do
      {:ok, _} -> errors
      {:error, rel_errors} -> rel_errors ++ errors
    end
  end

  defp validate_backend_ref(%BackendRef{} = backend) do
    errors = []

    errors =
      if is_nil(backend.id) do
        ["id must be a non-nil atom" | errors]
      else
        errors
      end

    finalize_validation(errors, backend)
  end

  defp validate_stage_def(%StageDef{} = stage) do
    errors = []

    errors =
      if is_nil(stage.name) do
        ["name must be a non-nil atom" | errors]
      else
        errors
      end

    finalize_validation(errors, stage)
  end

  defp validate_dataset_ref(%DatasetRef{} = dataset) do
    errors = []

    errors =
      if is_binary(dataset.name) and dataset.name == "" do
        ["name must be non-empty when set" | errors]
      else
        errors
      end

    finalize_validation(errors, dataset)
  end

  defp validate_output_spec(%OutputSpec{} = output) do
    errors = []

    errors =
      if is_nil(output.name) do
        ["name must be a non-nil atom" | errors]
      else
        errors
      end

    finalize_validation(errors, output)
  end

  defp validate_reliability_config(%Config{} = config) do
    []
    |> validate_optional(config.ensemble, "ensemble")
    |> validate_optional(config.hedging, "hedging")
    |> validate_optional(config.stats, "stats")
    |> validate_optional(config.fairness, "fairness")
    |> validate_optional(config.guardrails, "guardrails")
    |> validate_optional(config.feedback, "feedback")
    |> finalize_validation(config)
  end

  defp validate_ensemble(%Ensemble{} = ensemble) do
    valid_strategies = [:none, :majority, :weighted, :best_confidence, :unanimous]

    valid_execution_modes = [:parallel, :sequential, :hedged, :cascade]

    []
    |> validate_enum(ensemble.strategy, valid_strategies, "strategy")
    |> validate_enum(ensemble.execution_mode, valid_execution_modes, "execution_mode")
    |> finalize_validation(ensemble)
  end

  defp validate_hedging(%Hedging{} = hedging) do
    valid_strategies = [:off, :fixed, :percentile, :adaptive, :workload_aware]

    []
    |> validate_enum(hedging.strategy, valid_strategies, "strategy")
    |> finalize_validation(hedging)
  end

  defp validate_stats(%Stats{} = stats) do
    []
    |> validate_alpha(stats.alpha)
    |> finalize_validation(stats)
  end

  defp validate_fairness(%Fairness{} = fairness) do
    # Fairness currently has no required fields
    {:ok, fairness}
  end

  defp validate_guardrail(%Guardrail{} = guardrail) do
    # Guardrail currently has no required fields
    {:ok, guardrail}
  end

  defp validate_model_ref(%ModelRef{} = model) do
    errors = []

    errors =
      if is_nil(model.id) do
        ["id is required" | errors]
      else
        errors
      end

    finalize_validation(errors, model)
  end

  defp validate_model_version(%ModelVersion{} = version) do
    errors = []

    errors =
      if is_nil(version.id) do
        ["id is required" | errors]
      else
        errors
      end

    errors =
      if is_nil(version.model_id) do
        ["model_id is required" | errors]
      else
        errors
      end

    errors =
      if is_nil(version.version) or version.version == "" do
        ["version is required" | errors]
      else
        # Basic semver validation
        if is_binary(version.version) and not Regex.match?(~r/^\d+\.\d+\.\d+/, version.version) do
          ["version must be a valid semver format (e.g., 1.0.0)" | errors]
        else
          errors
        end
      end

    finalize_validation(errors, version)
  end

  defp validate_training_config(%Training.Config{} = config) do
    []
    |> validate_required_field(config.id, "id")
    |> validate_required_field(config.model_ref, "model_ref")
    |> validate_required_field(config.dataset_ref, "dataset_ref")
    |> validate_positive_or_nil(config.epochs, "epochs")
    |> validate_positive_or_nil(config.batch_size, "batch_size")
    |> validate_strictly_positive_or_nil(config.learning_rate, "learning_rate")
    |> finalize_validation(config)
  end

  defp validate_training_run(%Training.Run{} = run) do
    valid_statuses = [:pending, :running, :completed, :failed, :cancelled]

    []
    |> validate_required_field(run.id, "id")
    |> validate_required_field(run.config, "config")
    |> validate_enum(run.status, valid_statuses, "status")
    |> finalize_validation(run)
  end

  defp validate_deployment_config(%Deployment.Config{} = config) do
    []
    |> validate_required_field(config.id, "id")
    |> validate_required_field(config.model_version_id, "model_version_id")
    |> validate_positive_or_nil(config.replicas, "replicas")
    |> finalize_validation(config)
  end

  defp validate_deployment_status(%Deployment.Status{} = status) do
    valid_states = [:pending, :deploying, :active, :degraded, :failed, :terminated]

    []
    |> validate_required_field(status.id, "id")
    |> validate_required_field(status.deployment_id, "deployment_id")
    |> validate_enum(status.state, valid_states, "state")
    |> finalize_validation(status)
  end

  defp validate_feedback_event(%Feedback.Event{} = event) do
    errors = []

    errors =
      if is_nil(event.id) or event.id == "" do
        ["id is required" | errors]
      else
        errors
      end

    finalize_validation(errors, event)
  end

  defp validate_feedback_config(%Feedback.Config{} = config) do
    []
    |> validate_sampling_rate(config.sampling_rate)
    |> finalize_validation(config)
  end

  defp validate_optional(errors, nil, _prefix), do: errors

  defp validate_optional(errors, value, prefix) do
    case validate(value) do
      {:ok, _} -> errors
      {:error, nested_errors} -> Enum.map(nested_errors, &"#{prefix}.#{&1}") ++ errors
    end
  end

  defp validate_enum(errors, value, valid_values, field_name) do
    if value in valid_values do
      errors
    else
      ["#{field_name} must be one of: #{Enum.join(valid_values, ", ")}" | errors]
    end
  end

  defp validate_alpha(errors, nil), do: errors

  defp validate_alpha(errors, alpha) do
    if alpha >= 0 and alpha <= 1 do
      errors
    else
      ["alpha must be between 0 and 1" | errors]
    end
  end

  defp validate_required_field(errors, nil, field_name) do
    ["#{field_name} is required" | errors]
  end

  defp validate_required_field(errors, _value, _field_name), do: errors

  defp validate_positive_or_nil(errors, nil, _field), do: errors

  defp validate_positive_or_nil(errors, value, field) do
    if value >= 1 do
      errors
    else
      ["#{field} must be positive" | errors]
    end
  end

  defp validate_strictly_positive_or_nil(errors, nil, _field), do: errors

  defp validate_strictly_positive_or_nil(errors, value, field) do
    if value > 0 do
      errors
    else
      ["#{field} must be positive" | errors]
    end
  end

  defp validate_sampling_rate(errors, nil), do: errors

  defp validate_sampling_rate(errors, rate) do
    if rate >= 0 and rate <= 1 do
      errors
    else
      ["sampling_rate must be between 0 and 1" | errors]
    end
  end

  defp finalize_validation([], struct), do: {:ok, struct}
  defp finalize_validation(errors, _struct), do: {:error, Enum.reverse(errors)}
end
