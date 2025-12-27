defmodule CrucibleIR.Builder do
  @moduledoc """
  Fluent builder API for constructing experiments.

  The Builder module provides a fluent, chainable API for building complex
  CrucibleIR experiments with validation. It simplifies the creation of
  experiments by providing convenience methods and automatic validation.

  ## Example

      {:ok, exp} =
        CrucibleIR.Builder.experiment(:my_exp)
        |> CrucibleIR.Builder.with_description("Test experiment")
        |> CrucibleIR.Builder.with_backend(:gpt4)
        |> CrucibleIR.Builder.add_stage(:inference)
        |> CrucibleIR.Builder.with_ensemble(:majority)
        |> CrucibleIR.Builder.with_stats([:ttest], alpha: 0.01)
        |> CrucibleIR.Builder.build()

  ## Fluent API

  All builder functions return the modified experiment struct, allowing
  for method chaining. Use `build/1` at the end to validate and finalize.
  """

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
  alias CrucibleIR.Validation

  @type builder_experiment :: %Experiment{
          id: atom(),
          backend: BackendRef.t() | nil,
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

  @doc """
  Creates a new experiment builder with the given ID.

  ## Parameters

  - `id` - Atom identifier for the experiment

  ## Returns

  An Experiment struct with only the id set (incomplete, not validated).

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> exp.id
      :test
  """
  @spec experiment(atom()) :: builder_experiment()
  def experiment(id) when is_atom(id) do
    %Experiment{
      id: id,
      backend: nil,
      pipeline: []
    }
  end

  @doc """
  Adds a description to the experiment.

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_description("My experiment")
      iex> exp.description
      "My experiment"
  """
  @spec with_description(builder_experiment(), String.t()) :: builder_experiment()
  def with_description(%Experiment{} = exp, description) when is_binary(description) do
    %{exp | description: description}
  end

  @doc """
  Adds a backend to the experiment.

  ## Parameters

  - `exp` - Experiment struct
  - `backend_id` - Atom identifier for the backend
  - `opts` - Optional keyword list with `:profile` and `:options`

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_backend(:gpt4)
      iex> exp.backend.id
      :gpt4

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_backend(:gpt4, profile: :fast, options: %{temp: 0.7})
      iex> exp.backend.profile
      :fast
  """
  @spec with_backend(builder_experiment(), atom(), keyword()) :: builder_experiment()
  def with_backend(%Experiment{} = exp, backend_id, opts \\ []) when is_atom(backend_id) do
    backend = %BackendRef{
      id: backend_id,
      profile: Keyword.get(opts, :profile, :default),
      options: Keyword.get(opts, :options)
    }

    %{exp | backend: backend}
  end

  @doc """
  Adds a stage to the experiment pipeline.

  ## Parameters

  - `exp` - Experiment struct
  - `stage_name` - Atom name for the stage
  - `opts` - Optional keyword list with `:module`, `:options`, `:enabled`

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.add_stage(:preprocessing)
      iex> hd(exp.pipeline).name
      :preprocessing

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.add_stage(:preprocessing, enabled: false)
      iex> hd(exp.pipeline).enabled
      false
  """
  @spec add_stage(builder_experiment(), atom(), keyword()) :: builder_experiment()
  def add_stage(%Experiment{} = exp, stage_name, opts \\ []) when is_atom(stage_name) do
    stage = %StageDef{
      name: stage_name,
      module: Keyword.get(opts, :module),
      options: Keyword.get(opts, :options),
      enabled: Keyword.get(opts, :enabled, true)
    }

    pipeline = (exp.pipeline || []) ++ [stage]
    %{exp | pipeline: pipeline}
  end

  @doc """
  Adds a dataset to the experiment.

  ## Parameters

  - `exp` - Experiment struct
  - `dataset_name` - Atom or string name for the dataset
  - `opts` - Optional keyword list with `:provider`, `:split`, `:options`

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_dataset(:mmlu)
      iex> exp.dataset.name
      :mmlu

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_dataset(:mmlu, split: :test)
      iex> exp.dataset.split
      :test
  """
  @spec with_dataset(builder_experiment(), atom() | String.t(), keyword()) :: builder_experiment()
  def with_dataset(%Experiment{} = exp, dataset_name, opts \\ []) do
    dataset = %DatasetRef{
      name: dataset_name,
      provider: Keyword.get(opts, :provider, :crucible_datasets),
      split: Keyword.get(opts, :split, :train),
      options: Keyword.get(opts, :options)
    }

    %{exp | dataset: dataset}
  end

  @doc """
  Adds ensemble voting configuration to the experiment.

  ## Parameters

  - `exp` - Experiment struct
  - `strategy` - Voting strategy atom
  - `opts` - Optional keyword list with ensemble options

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_ensemble(:majority)
      iex> exp.reliability.ensemble.strategy
      :majority

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_ensemble(:weighted, models: [:gpt4, :claude])
      iex> exp.reliability.ensemble.models
      [:gpt4, :claude]
  """
  @spec with_ensemble(builder_experiment(), atom(), keyword()) :: builder_experiment()
  def with_ensemble(%Experiment{} = exp, strategy, opts \\ []) when is_atom(strategy) do
    ensemble = %Ensemble{
      strategy: strategy,
      execution_mode: Keyword.get(opts, :execution_mode, :parallel),
      models: Keyword.get(opts, :models),
      weights: Keyword.get(opts, :weights),
      min_agreement: Keyword.get(opts, :min_agreement),
      timeout_ms: Keyword.get(opts, :timeout_ms),
      options: Keyword.get(opts, :options)
    }

    reliability = get_or_create_reliability(exp)
    reliability = %{reliability | ensemble: ensemble}
    %{exp | reliability: reliability}
  end

  @doc """
  Adds request hedging configuration to the experiment.

  ## Parameters

  - `exp` - Experiment struct
  - `strategy` - Hedging strategy atom
  - `opts` - Optional keyword list with hedging options

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_hedging(:fixed)
      iex> exp.reliability.hedging.strategy
      :fixed

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_hedging(:percentile, delay_ms: 100)
      iex> exp.reliability.hedging.delay_ms
      100
  """
  @spec with_hedging(builder_experiment(), atom(), keyword()) :: builder_experiment()
  def with_hedging(%Experiment{} = exp, strategy, opts \\ []) when is_atom(strategy) do
    hedging = %Hedging{
      strategy: strategy,
      delay_ms: Keyword.get(opts, :delay_ms),
      percentile: Keyword.get(opts, :percentile),
      max_hedges: Keyword.get(opts, :max_hedges),
      budget_percent: Keyword.get(opts, :budget_percent),
      options: Keyword.get(opts, :options)
    }

    reliability = get_or_create_reliability(exp)
    reliability = %{reliability | hedging: hedging}
    %{exp | reliability: reliability}
  end

  @doc """
  Adds statistical testing configuration to the experiment.

  ## Parameters

  - `exp` - Experiment struct
  - `tests` - List of statistical test atoms
  - `opts` - Optional keyword list with stats options

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_stats([:ttest])
      iex> exp.reliability.stats.tests
      [:ttest]

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_stats([:ttest, :bootstrap], alpha: 0.01)
      iex> exp.reliability.stats.alpha
      0.01
  """
  @spec with_stats(builder_experiment(), [atom()], keyword()) :: builder_experiment()
  def with_stats(%Experiment{} = exp, tests, opts \\ []) when is_list(tests) do
    stats = %Stats{
      tests: tests,
      alpha: Keyword.get(opts, :alpha, 0.05),
      confidence_level: Keyword.get(opts, :confidence_level),
      effect_size_type: Keyword.get(opts, :effect_size_type),
      multiple_testing_correction: Keyword.get(opts, :multiple_testing_correction),
      bootstrap_iterations: Keyword.get(opts, :bootstrap_iterations),
      options: Keyword.get(opts, :options)
    }

    reliability = get_or_create_reliability(exp)
    reliability = %{reliability | stats: stats}
    %{exp | reliability: reliability}
  end

  @doc """
  Adds fairness checking configuration to the experiment.

  ## Parameters

  - `exp` - Experiment struct
  - `opts` - Keyword list with fairness options

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_fairness(metrics: [:demographic_parity])
      iex> exp.reliability.fairness.metrics
      [:demographic_parity]

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_fairness(threshold: 0.8, enabled: true)
      iex> exp.reliability.fairness.threshold
      0.8
  """
  @spec with_fairness(builder_experiment(), keyword()) :: builder_experiment()
  def with_fairness(%Experiment{} = exp, opts \\ []) do
    fairness = %Fairness{
      enabled: Keyword.get(opts, :enabled, true),
      metrics: Keyword.get(opts, :metrics),
      group_by: Keyword.get(opts, :group_by),
      threshold: Keyword.get(opts, :threshold),
      fail_on_violation: Keyword.get(opts, :fail_on_violation),
      options: Keyword.get(opts, :options)
    }

    reliability = get_or_create_reliability(exp)
    reliability = %{reliability | fairness: fairness}
    %{exp | reliability: reliability}
  end

  @doc """
  Adds guardrails configuration to the experiment.

  ## Parameters

  - `exp` - Experiment struct
  - `opts` - Keyword list with guardrail options

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_guardrails(profiles: [:strict])
      iex> exp.reliability.guardrails.profiles
      [:strict]

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_guardrails(pii_detection: true)
      iex> exp.reliability.guardrails.pii_detection
      true
  """
  @spec with_guardrails(builder_experiment(), keyword()) :: builder_experiment()
  def with_guardrails(%Experiment{} = exp, opts \\ []) do
    guardrail = %Guardrail{
      profiles: Keyword.get(opts, :profiles, [:default]),
      prompt_injection_detection: Keyword.get(opts, :prompt_injection_detection),
      jailbreak_detection: Keyword.get(opts, :jailbreak_detection),
      pii_detection: Keyword.get(opts, :pii_detection),
      pii_redaction: Keyword.get(opts, :pii_redaction),
      content_moderation: Keyword.get(opts, :content_moderation),
      fail_on_detection: Keyword.get(opts, :fail_on_detection),
      options: Keyword.get(opts, :options)
    }

    reliability = get_or_create_reliability(exp)
    reliability = %{reliability | guardrails: guardrail}
    %{exp | reliability: reliability}
  end

  @doc """
  Adds an output specification to the experiment.

  ## Parameters

  - `exp` - Experiment struct
  - `name` - Atom name for the output
  - `opts` - Optional keyword list with `:formats`, `:sink`, `:options`

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.add_output(:results)
      iex> hd(exp.outputs).name
      :results

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.add_output(:results, formats: [:json, :html])
      iex> hd(exp.outputs).formats
      [:json, :html]
  """
  @spec add_output(builder_experiment(), atom(), keyword()) :: builder_experiment()
  def add_output(%Experiment{} = exp, name, opts \\ []) when is_atom(name) do
    output = %OutputSpec{
      name: name,
      formats: Keyword.get(opts, :formats, [:markdown]),
      sink: Keyword.get(opts, :sink, :file),
      options: Keyword.get(opts, :options)
    }

    outputs = (exp.outputs || []) ++ [output]
    %{exp | outputs: outputs}
  end

  @doc """
  Sets the experiment type.

  ## Parameters

  - `exp` - Experiment struct
  - `type` - Experiment type (:evaluation, :training, :comparison, :ablation)

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_experiment_type(:evaluation)
      iex> exp.experiment_type
      :evaluation
  """
  @spec with_experiment_type(builder_experiment(), atom()) :: builder_experiment()
  def with_experiment_type(%Experiment{} = exp, type) when is_atom(type) do
    %{exp | experiment_type: type}
  end

  @doc """
  Sets a model version for the experiment.

  ## Parameters

  - `exp` - Experiment struct
  - `model_id` - Model identifier
  - `version` - Version string
  - `opts` - Optional keyword list with version options

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_model_version(:gpt2, "1.0.0")
      iex> exp.model_version.version
      "1.0.0"
  """
  @spec with_model_version(builder_experiment(), atom(), String.t(), keyword()) ::
          builder_experiment()
  def with_model_version(%Experiment{} = exp, model_id, version, opts \\ []) do
    model_version = %ModelVersion{
      id: Keyword.get(opts, :id, :"#{model_id}_#{String.replace(version, ".", "_")}"),
      model_id: model_id,
      version: version,
      stage: Keyword.get(opts, :stage, :development),
      metrics: Keyword.get(opts, :metrics),
      artifact_uri: Keyword.get(opts, :artifact_uri)
    }

    %{exp | model_version: model_version}
  end

  @doc """
  Sets a baseline model for comparison experiments.

  ## Parameters

  - `exp` - Experiment struct
  - `model_id` - Baseline model identifier
  - `opts` - Optional keyword list with model options

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_baseline(:gpt3)
      iex> exp.baseline.id
      :gpt3
  """
  @spec with_baseline(builder_experiment(), atom(), keyword()) :: builder_experiment()
  def with_baseline(%Experiment{} = exp, model_id, opts \\ []) when is_atom(model_id) do
    baseline = %ModelRef{
      id: model_id,
      provider: Keyword.get(opts, :provider, :local),
      framework: Keyword.get(opts, :framework, :nx),
      version: Keyword.get(opts, :version)
    }

    %{exp | baseline: baseline}
  end

  @doc """
  Adds feedback collection configuration to the experiment.

  ## Parameters

  - `exp` - Experiment struct
  - `opts` - Keyword list with feedback options

  ## Examples

      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_feedback(enabled: true, sampling_rate: 0.1)
      iex> exp.reliability.feedback.sampling_rate
      0.1
  """
  @spec with_feedback(builder_experiment(), keyword()) :: builder_experiment()
  def with_feedback(%Experiment{} = exp, opts \\ []) do
    feedback = %Feedback.Config{
      enabled: Keyword.get(opts, :enabled, true),
      sampling_rate: Keyword.get(opts, :sampling_rate, 1.0),
      feedback_types: Keyword.get(opts, :feedback_types, [:thumbs, :correction]),
      storage: Keyword.get(opts, :storage, :postgres),
      anonymize_pii: Keyword.get(opts, :anonymize_pii, true),
      retention_days: Keyword.get(opts, :retention_days),
      options: Keyword.get(opts, :options)
    }

    reliability = get_or_create_reliability(exp)
    reliability = %{reliability | feedback: feedback}
    %{exp | reliability: reliability}
  end

  @doc """
  Adds training configuration to the experiment.

  ## Parameters

  - `exp` - Experiment struct
  - `model_ref` - ModelRef struct or keyword to create one
  - `dataset_ref` - DatasetRef struct or keyword to create one
  - `opts` - Optional keyword list with training options

  ## Examples

      iex> model = %CrucibleIR.ModelRef{id: :gpt2}
      iex> dataset = %CrucibleIR.DatasetRef{name: :wikitext}
      iex> exp = CrucibleIR.Builder.experiment(:test)
      iex> |> CrucibleIR.Builder.with_training_config(model, dataset, epochs: 10)
      iex> exp.training_config.epochs
      10
  """
  @spec with_training_config(builder_experiment(), ModelRef.t(), DatasetRef.t(), keyword()) ::
          builder_experiment()
  def with_training_config(%Experiment{} = exp, %ModelRef{} = model_ref, dataset_ref, opts \\ []) do
    training_config = %Training.Config{
      id: Keyword.get(opts, :id, :"train_#{exp.id}"),
      model_ref: model_ref,
      dataset_ref: dataset_ref,
      epochs: Keyword.get(opts, :epochs, 1),
      batch_size: Keyword.get(opts, :batch_size, 32),
      learning_rate: Keyword.get(opts, :learning_rate, 0.001),
      optimizer: Keyword.get(opts, :optimizer, :adam),
      device: Keyword.get(opts, :device, :cpu),
      options: Keyword.get(opts, :options)
    }

    %{exp | training_config: training_config}
  end

  @doc """
  Validates and finalizes the experiment.

  Returns `{:ok, experiment}` if valid, or `{:error, errors}` if invalid.

  ## Examples

      iex> {:ok, exp} = CrucibleIR.Builder.experiment(:test)
      ...> |> CrucibleIR.Builder.with_backend(:gpt4)
      ...> |> CrucibleIR.Builder.add_stage(:run)
      ...> |> CrucibleIR.Builder.build()
      iex> exp.id
      :test

      iex> {:error, errors} = CrucibleIR.Builder.experiment(:test)
      ...> |> CrucibleIR.Builder.build()
      iex> is_list(errors)
      true
  """
  @spec build(builder_experiment()) :: {:ok, Experiment.t()} | {:error, [String.t()]}
  def build(%Experiment{} = exp) do
    Validation.validate(exp)
  end

  # Private helper functions

  defp get_or_create_reliability(%Experiment{reliability: nil}) do
    %Config{}
  end

  defp get_or_create_reliability(%Experiment{reliability: config}) do
    config
  end
end
