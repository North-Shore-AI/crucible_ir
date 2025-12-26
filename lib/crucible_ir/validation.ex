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

  alias CrucibleIR.{Experiment, BackendRef, StageDef, DatasetRef, OutputSpec}
  alias CrucibleIR.{ModelRef, ModelVersion}
  alias CrucibleIR.Training
  alias CrucibleIR.Deployment
  alias CrucibleIR.Feedback
  alias CrucibleIR.Reliability.{Config, Ensemble, Hedging, Stats, Fairness, Guardrail}

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
    errors = []

    errors =
      if is_nil(exp.id) or exp.id == :"" do
        ["id must be non-empty atom" | errors]
      else
        errors
      end

    errors =
      if is_nil(exp.backend) do
        ["backend is required" | errors]
      else
        case validate(exp.backend) do
          {:ok, _} -> errors
          {:error, backend_errors} -> Enum.map(backend_errors, &"backend.#{&1}") ++ errors
        end
      end

    errors =
      cond do
        is_nil(exp.pipeline) ->
          ["pipeline must be a list" | errors]

        not is_list(exp.pipeline) ->
          ["pipeline must be a list" | errors]

        Enum.empty?(exp.pipeline) ->
          ["pipeline must contain at least one stage" | errors]

        true ->
          exp.pipeline
          |> Enum.with_index()
          |> Enum.reduce(errors, fn {stage, _idx}, acc ->
            case validate(stage) do
              {:ok, _} -> acc
              {:error, stage_errors} -> Enum.map(stage_errors, &"pipeline stage #{&1}") ++ acc
            end
          end)
      end

    errors =
      if not is_nil(exp.reliability) do
        case validate(exp.reliability) do
          {:ok, _} -> errors
          {:error, rel_errors} -> rel_errors ++ errors
        end
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, exp}
    else
      {:error, Enum.reverse(errors)}
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

    if Enum.empty?(errors) do
      {:ok, backend}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_stage_def(%StageDef{} = stage) do
    errors = []

    errors =
      if is_nil(stage.name) do
        ["name must be a non-nil atom" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, stage}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_dataset_ref(%DatasetRef{} = dataset) do
    errors = []

    errors =
      if is_binary(dataset.name) and dataset.name == "" do
        ["name must be non-empty when set" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, dataset}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_output_spec(%OutputSpec{} = output) do
    errors = []

    errors =
      if is_nil(output.name) do
        ["name must be a non-nil atom" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, output}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_reliability_config(%Config{} = config) do
    errors = []

    errors =
      if not is_nil(config.ensemble) do
        case validate(config.ensemble) do
          {:ok, _} -> errors
          {:error, ens_errors} -> Enum.map(ens_errors, &"ensemble.#{&1}") ++ errors
        end
      else
        errors
      end

    errors =
      if not is_nil(config.hedging) do
        case validate(config.hedging) do
          {:ok, _} -> errors
          {:error, hedge_errors} -> Enum.map(hedge_errors, &"hedging.#{&1}") ++ errors
        end
      else
        errors
      end

    errors =
      if not is_nil(config.stats) do
        case validate(config.stats) do
          {:ok, _} -> errors
          {:error, stats_errors} -> Enum.map(stats_errors, &"stats.#{&1}") ++ errors
        end
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, config}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_ensemble(%Ensemble{} = ensemble) do
    errors = []

    valid_strategies = [:none, :majority, :weighted, :best_confidence, :unanimous]

    errors =
      if ensemble.strategy not in valid_strategies do
        ["strategy must be one of: #{Enum.join(valid_strategies, ", ")}" | errors]
      else
        errors
      end

    valid_execution_modes = [:parallel, :sequential, :hedged, :cascade]

    errors =
      if ensemble.execution_mode not in valid_execution_modes do
        ["execution_mode must be one of: #{Enum.join(valid_execution_modes, ", ")}" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, ensemble}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_hedging(%Hedging{} = hedging) do
    errors = []

    valid_strategies = [:off, :fixed, :percentile, :adaptive, :workload_aware]

    errors =
      if hedging.strategy not in valid_strategies do
        ["strategy must be one of: #{Enum.join(valid_strategies, ", ")}" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, hedging}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_stats(%Stats{} = stats) do
    errors = []

    errors =
      if not is_nil(stats.alpha) and (stats.alpha < 0 or stats.alpha > 1) do
        ["alpha must be between 0 and 1" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, stats}
    else
      {:error, Enum.reverse(errors)}
    end
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

    if Enum.empty?(errors) do
      {:ok, model}
    else
      {:error, Enum.reverse(errors)}
    end
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

    if Enum.empty?(errors) do
      {:ok, version}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_training_config(%Training.Config{} = config) do
    errors = []

    errors =
      if is_nil(config.id) do
        ["id is required" | errors]
      else
        errors
      end

    errors =
      if is_nil(config.model_ref) do
        ["model_ref is required" | errors]
      else
        errors
      end

    errors =
      if is_nil(config.dataset_ref) do
        ["dataset_ref is required" | errors]
      else
        errors
      end

    errors =
      if not is_nil(config.epochs) and config.epochs < 1 do
        ["epochs must be positive" | errors]
      else
        errors
      end

    errors =
      if not is_nil(config.batch_size) and config.batch_size < 1 do
        ["batch_size must be positive" | errors]
      else
        errors
      end

    errors =
      if not is_nil(config.learning_rate) and config.learning_rate <= 0 do
        ["learning_rate must be positive" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, config}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_training_run(%Training.Run{} = run) do
    errors = []

    errors =
      if is_nil(run.id) do
        ["id is required" | errors]
      else
        errors
      end

    errors =
      if is_nil(run.config) do
        ["config is required" | errors]
      else
        errors
      end

    valid_statuses = [:pending, :running, :completed, :failed, :cancelled]

    errors =
      if run.status not in valid_statuses do
        ["status must be one of: #{Enum.join(valid_statuses, ", ")}" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, run}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_deployment_config(%Deployment.Config{} = config) do
    errors = []

    errors =
      if is_nil(config.id) do
        ["id is required" | errors]
      else
        errors
      end

    errors =
      if is_nil(config.model_version_id) do
        ["model_version_id is required" | errors]
      else
        errors
      end

    errors =
      if not is_nil(config.replicas) and config.replicas < 1 do
        ["replicas must be positive" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, config}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_deployment_status(%Deployment.Status{} = status) do
    errors = []

    errors =
      if is_nil(status.id) do
        ["id is required" | errors]
      else
        errors
      end

    errors =
      if is_nil(status.deployment_id) do
        ["deployment_id is required" | errors]
      else
        errors
      end

    valid_states = [:pending, :deploying, :active, :degraded, :failed, :terminated]

    errors =
      if status.state not in valid_states do
        ["state must be one of: #{Enum.join(valid_states, ", ")}" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, status}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_feedback_event(%Feedback.Event{} = event) do
    errors = []

    errors =
      if is_nil(event.id) or event.id == "" do
        ["id is required" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, event}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_feedback_config(%Feedback.Config{} = config) do
    errors = []

    errors =
      if not is_nil(config.sampling_rate) and
           (config.sampling_rate < 0 or config.sampling_rate > 1) do
        ["sampling_rate must be between 0 and 1" | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, config}
    else
      {:error, Enum.reverse(errors)}
    end
  end
end
