defmodule CrucibleIR.Serialization do
  @moduledoc """
  JSON serialization and deserialization for IR structs.

  This module provides functions to convert CrucibleIR structs to and from
  JSON, enabling persistence, transport, and interoperability with other systems.

  ## Functions

  - `to_json/1` - Encode struct to JSON string
  - `from_json/2` - Decode JSON string to struct of given type
  - `from_map/2` - Convert plain map to struct

  ## Contract Notes

  - This module is the canonical JSON round-trip layer for CrucibleIR.
  - Fields like `options` and `StageDef.options` are treated as opaque maps and
    are not coerced or validated.
  - For stable round-trip behavior, ensure map keys are JSON-friendly (strings).

  ## Examples

      iex> alias CrucibleIR.BackendRef
      iex> backend = %BackendRef{id: :gpt4}
      iex> json = CrucibleIR.Serialization.to_json(backend)
      iex> is_binary(json)
      true

      iex> alias CrucibleIR.BackendRef
      iex> json = ~s({"id":"gpt4","profile":"default"})
      iex> {:ok, backend} = CrucibleIR.Serialization.from_json(json, BackendRef)
      iex> backend.id
      :gpt4
  """

  alias CrucibleIR.Deployment
  alias CrucibleIR.Feedback

  alias CrucibleIR.Backend.{Capabilities, Completion, Options, Prompt}

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

  @experiment_fields ~w(id backend pipeline description owner tags metadata dataset reliability outputs created_at updated_at experiment_type model_version training_config baseline)a
  @backend_ref_fields ~w(id profile options model_version endpoint_url deployment_id fallback)a
  @backend_prompt_fields ~w(messages system tools tool_choice options request_id trace_id metadata)a
  @backend_prompt_message_fields ~w(role content name tool_calls tool_call_id)a
  @backend_prompt_content_part_fields ~w(type text url media_type base64 format tool_call_id content)a
  @backend_tool_call_fields ~w(id name arguments)a
  @backend_options_fields ~w(model temperature max_tokens top_p top_k frequency_penalty presence_penalty stop response_format json_schema stream cache_control extended_thinking thinking_budget_tokens seed timeout_ms extra)a
  @backend_completion_fields ~w(choices model usage latency_ms time_to_first_token_ms request_id trace_id raw_response metadata)a
  @backend_completion_choice_fields ~w(index message finish_reason thinking)a
  @backend_completion_usage_fields ~w(prompt_tokens completion_tokens total_tokens thinking_tokens cached_tokens)a
  @backend_capabilities_fields ~w(backend_id provider models default_model supports_streaming supports_tools supports_vision supports_audio supports_json_mode supports_extended_thinking supports_caching max_tokens max_context_length max_images_per_request requests_per_minute tokens_per_minute cost_per_million_input cost_per_million_output metadata)a
  @stage_def_fields ~w(name module options enabled)a
  @dataset_ref_fields ~w(name provider split options version format schema)a
  @output_spec_fields ~w(name formats sink options)a
  @config_fields ~w(ensemble hedging guardrails stats fairness monitoring drift circuit_breaker feedback)a
  @ensemble_fields ~w(strategy execution_mode models weights min_agreement timeout_ms options)a
  @hedging_fields ~w(strategy delay_ms percentile max_hedges budget_percent options)a
  @stats_fields ~w(tests alpha confidence_level effect_size_type multiple_testing_correction bootstrap_iterations options)a
  @fairness_fields ~w(enabled metrics group_by threshold fail_on_violation options)a
  @guardrail_fields ~w(profiles prompt_injection_detection jailbreak_detection pii_detection pii_redaction content_moderation fail_on_detection options)a
  @model_ref_fields ~w(id name version provider framework architecture task artifact_uri metadata options)a
  @model_version_fields ~w(id model_id version stage training_run_id metrics artifact_uri parent_version description created_at created_by options)a
  @training_config_fields ~w(id model_ref dataset_ref epochs batch_size learning_rate optimizer loss_function metrics validation_split device seed mixed_precision gradient_clipping early_stopping checkpoint_every options)a
  @training_run_fields ~w(id config status current_epoch metrics_history best_metrics checkpoint_uris final_model_version started_at completed_at error_message options)a
  @deployment_config_fields ~w(id model_version_id target replicas resources scaling environment strategy health_check endpoint metadata options)a
  @deployment_status_fields ~w(id deployment_id state ready_replicas total_replicas endpoint_url traffic_percent health last_health_check error_message created_at updated_at)a
  @feedback_event_fields ~w(id deployment_id model_version input output feedback_type feedback_value user_id session_id latency_ms timestamp metadata)a
  @feedback_config_fields ~w(enabled sampling_rate feedback_types storage retention_days anonymize_pii drift_detection retraining_trigger options)a

  @doc """
  Encodes a struct to a JSON string.

  ## Parameters

  - `struct` - Any CrucibleIR struct with `@derive Jason.Encoder`

  ## Returns

  - JSON string representation

  ## Examples

      iex> alias CrucibleIR.BackendRef
      iex> backend = %BackendRef{id: :gpt4}
      iex> json = CrucibleIR.Serialization.to_json(backend)
      iex> is_binary(json)
      true
  """
  @spec to_json(struct()) :: String.t()
  def to_json(struct) do
    Jason.encode!(struct)
  end

  @doc """
  Decodes a JSON string to a struct of the given type.

  ## Parameters

  - `json` - JSON string to decode
  - `type` - The module name of the target struct type

  ## Returns

  - `{:ok, struct}` - Successfully decoded struct
  - `{:error, reason}` - Decoding failed

  ## Examples

      iex> alias CrucibleIR.BackendRef
      iex> json = ~s({"id":"gpt4","profile":"default"})
      iex> {:ok, backend} = CrucibleIR.Serialization.from_json(json, BackendRef)
      iex> backend.id
      :gpt4
  """
  @spec from_json(String.t(), module()) :: {:ok, struct()} | {:error, term()}
  def from_json(json, type) when is_binary(json) do
    with {:ok, map} <- Jason.decode(json) do
      from_map(map, type)
    end
  end

  @doc """
  Converts a plain map to a struct of the given type.

  Handles conversion of string keys to atoms and nested struct construction.

  ## Parameters

  - `map` - Map with string or atom keys
  - `type` - The module name of the target struct type

  ## Returns

  - `{:ok, struct}` - Successfully converted struct
  - `{:error, reason}` - Conversion failed

  ## Examples

      iex> alias CrucibleIR.BackendRef
      iex> map = %{"id" => "gpt4", "profile" => "default"}
      iex> {:ok, backend} = CrucibleIR.Serialization.from_map(map, BackendRef)
      iex> backend.id
      :gpt4
  """
  @spec from_map(map(), module()) :: {:ok, struct()} | {:error, term()}
  def from_map(map, Experiment) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@experiment_fields)
        |> convert_experiment_fields()

      struct!(Experiment, attrs)
    end)
  end

  def from_map(map, BackendRef) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@backend_ref_fields)
        |> convert_backend_ref_fields()

      struct!(BackendRef, attrs)
    end)
  end

  def from_map(map, Prompt) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@backend_prompt_fields)
        |> convert_prompt_fields()

      struct!(Prompt, attrs)
    end)
  end

  def from_map(map, Options) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@backend_options_fields)
        |> convert_options_fields()

      struct!(Options, attrs)
    end)
  end

  def from_map(map, Completion) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@backend_completion_fields)
        |> convert_completion_fields()

      struct!(Completion, attrs)
    end)
  end

  def from_map(map, Capabilities) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@backend_capabilities_fields)
        |> convert_capabilities_fields()

      struct!(Capabilities, attrs)
    end)
  end

  def from_map(map, StageDef) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@stage_def_fields)
        |> convert_stage_def_fields()

      struct!(StageDef, attrs)
    end)
  end

  def from_map(map, DatasetRef) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@dataset_ref_fields)
        |> convert_dataset_ref_fields()

      struct!(DatasetRef, attrs)
    end)
  end

  def from_map(map, OutputSpec) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@output_spec_fields)
        |> convert_output_spec_fields()

      struct!(OutputSpec, attrs)
    end)
  end

  def from_map(map, Config) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@config_fields)
        |> convert_reliability_config_fields()

      struct!(Config, attrs)
    end)
  end

  def from_map(map, Ensemble) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@ensemble_fields)
        |> convert_ensemble_fields()

      struct!(Ensemble, attrs)
    end)
  end

  def from_map(map, Hedging) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@hedging_fields)
        |> convert_hedging_fields()

      struct!(Hedging, attrs)
    end)
  end

  def from_map(map, Stats) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@stats_fields)
        |> convert_stats_fields()

      struct!(Stats, attrs)
    end)
  end

  def from_map(map, Fairness) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@fairness_fields)
        |> convert_fairness_fields()

      struct!(Fairness, attrs)
    end)
  end

  def from_map(map, Guardrail) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@guardrail_fields)
        |> convert_guardrail_fields()

      struct!(Guardrail, attrs)
    end)
  end

  def from_map(map, ModelRef) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@model_ref_fields)
        |> convert_model_ref_fields()

      struct!(ModelRef, attrs)
    end)
  end

  def from_map(map, ModelVersion) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@model_version_fields)
        |> convert_model_version_fields()

      struct!(ModelVersion, attrs)
    end)
  end

  def from_map(map, Training.Config) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@training_config_fields)
        |> convert_training_config_fields()

      struct!(Training.Config, attrs)
    end)
  end

  def from_map(map, Training.Run) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@training_run_fields)
        |> convert_training_run_fields()

      struct!(Training.Run, attrs)
    end)
  end

  def from_map(map, Deployment.Config) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@deployment_config_fields)
        |> convert_deployment_config_fields()

      struct!(Deployment.Config, attrs)
    end)
  end

  def from_map(map, Deployment.Status) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@deployment_status_fields)
        |> convert_deployment_status_fields()

      struct!(Deployment.Status, attrs)
    end)
  end

  def from_map(map, Feedback.Event) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@feedback_event_fields)
        |> convert_feedback_event_fields()

      struct!(Feedback.Event, attrs)
    end)
  end

  def from_map(map, Feedback.Config) when is_map(map) do
    try_from_map(fn ->
      attrs =
        map
        |> atomize_keys(@feedback_config_fields)
        |> convert_feedback_config_fields()

      struct!(Feedback.Config, attrs)
    end)
  end

  # Private helper functions

  defp atomize_keys(map, allowed_fields) when is_map(map) do
    allowed_strings = MapSet.new(allowed_fields, &Atom.to_string/1)

    Enum.reduce(map, %{}, fn {k, v}, acc ->
      atomize_key_value(acc, k, v, allowed_fields, allowed_strings)
    end)
  end

  defp atomize_key_value(acc, key, value, allowed_fields, allowed_strings) do
    cond do
      is_atom(key) and key in allowed_fields ->
        Map.put(acc, key, value)

      is_binary(key) and MapSet.member?(allowed_strings, key) ->
        safe_existing_atom_or_put(acc, key, value)

      true ->
        acc
    end
  end

  defp safe_existing_atom_or_put(acc, key, value) do
    case safe_existing_atom(key) do
      {:ok, atom} -> Map.put(acc, atom, value)
      :error -> acc
    end
  end

  defp convert_experiment_fields(attrs) do
    attrs
    |> convert_field(:id, &to_existing_atom/1)
    |> convert_field(:backend, fn map -> from_map!(map, BackendRef) end)
    |> convert_field(:pipeline, fn list ->
      Enum.map(list, fn stage_map -> from_map!(stage_map, StageDef) end)
    end)
    |> convert_field(:dataset, fn map -> from_map!(map, DatasetRef) end)
    |> convert_field(:reliability, fn map -> from_map!(map, Config) end)
    |> convert_field(:outputs, fn list ->
      Enum.map(list, fn output_map -> from_map!(output_map, OutputSpec) end)
    end)
    |> convert_field(:experiment_type, &to_existing_atom/1)
    |> convert_field(:model_version, fn
      %{} = map -> from_map!(map, ModelVersion)
      value -> value
    end)
    |> convert_field(:training_config, fn
      %{} = map -> from_map!(map, Training.Config)
      value -> value
    end)
    |> convert_field(:baseline, fn
      %{} = map -> from_map!(map, ModelRef)
      value -> value
    end)
    |> convert_field(:tags, fn list -> Enum.map(list, &to_existing_atom/1) end)
    |> convert_field(:created_at, &parse_datetime/1)
    |> convert_field(:updated_at, &parse_datetime/1)
  end

  defp convert_backend_ref_fields(attrs) do
    attrs
    |> convert_field(:id, &to_existing_atom/1)
    |> convert_field(:profile, &to_existing_atom/1)
    |> convert_field(:deployment_id, &to_existing_atom/1)
    |> convert_field(:fallback, fn
      %{} = map -> from_map!(map, BackendRef)
      value -> value
    end)
  end

  defp convert_prompt_fields(attrs) do
    attrs
    |> convert_field(:messages, &convert_prompt_messages/1)
    |> convert_field(:tool_choice, &normalize_tool_choice/1)
    |> convert_field(:options, fn
      %{} = map -> from_map!(map, Options)
      %Options{} = options -> options
      value -> value
    end)
  end

  defp convert_prompt_messages(messages) when is_list(messages) do
    Enum.map(messages, &convert_prompt_message/1)
  end

  defp convert_prompt_messages(value), do: value

  defp convert_prompt_message(%{} = message) do
    message
    |> atomize_keys(@backend_prompt_message_fields)
    |> convert_field(:role, &to_existing_atom/1)
    |> convert_field(:content, &convert_prompt_content/1)
    |> convert_field(:tool_calls, &convert_tool_calls/1)
  end

  defp convert_prompt_message({role, content}) do
    %{role: normalize_role(role), content: content}
  end

  defp convert_prompt_message(value), do: value

  defp convert_prompt_content(parts) when is_list(parts) do
    Enum.map(parts, &convert_prompt_content_part/1)
  end

  defp convert_prompt_content(value), do: value

  defp convert_prompt_content_part(%{} = part) do
    part
    |> atomize_keys(@backend_prompt_content_part_fields)
    |> convert_field(:type, &to_existing_atom/1)
  end

  defp convert_prompt_content_part(value), do: value

  defp convert_tool_calls(calls) when is_list(calls) do
    Enum.map(calls, &convert_tool_call/1)
  end

  defp convert_tool_calls(value), do: value

  defp convert_tool_call(%{} = call) do
    atomize_keys(call, @backend_tool_call_fields)
  end

  defp convert_tool_call(value), do: value

  defp normalize_role(role) when is_atom(role), do: role
  defp normalize_role("system"), do: :system
  defp normalize_role("user"), do: :user
  defp normalize_role("assistant"), do: :assistant
  defp normalize_role("tool"), do: :tool
  defp normalize_role(value), do: value

  defp normalize_tool_choice(%{} = choice) do
    case choice do
      %{"name" => name} -> %{name: name}
      %{name: name} -> %{name: name}
      _ -> choice
    end
  end

  defp normalize_tool_choice(value) when is_binary(value), do: to_existing_atom(value)
  defp normalize_tool_choice(value), do: value

  defp convert_options_fields(attrs) do
    attrs
    |> convert_field(:response_format, &to_existing_atom/1)
    |> convert_field(:cache_control, &to_existing_atom/1)
  end

  defp convert_completion_fields(attrs) do
    attrs
    |> convert_field(:choices, &convert_completion_choices/1)
    |> convert_field(:usage, &convert_completion_usage/1)
  end

  defp convert_completion_choices(choices) when is_list(choices) do
    Enum.map(choices, &convert_completion_choice/1)
  end

  defp convert_completion_choices(value), do: value

  defp convert_completion_choice(%{} = choice) do
    choice
    |> atomize_keys(@backend_completion_choice_fields)
    |> convert_field(:finish_reason, &to_existing_atom/1)
    |> convert_field(:message, &convert_prompt_message/1)
  end

  defp convert_completion_choice(value), do: value

  defp convert_completion_usage(%{} = usage) do
    atomize_keys(usage, @backend_completion_usage_fields)
  end

  defp convert_completion_usage(value), do: value

  defp convert_capabilities_fields(attrs) do
    attrs
    |> convert_field(:backend_id, &to_existing_atom/1)
  end

  defp convert_stage_def_fields(attrs) do
    attrs
    |> convert_field(:name, &to_existing_atom/1)
    |> convert_field(:module, &to_existing_atom/1)
  end

  defp convert_dataset_ref_fields(attrs) do
    attrs
    |> convert_field(:name, &normalize_dataset_name/1)
    |> convert_field(:provider, &to_existing_atom/1)
    |> convert_field(:split, &to_existing_atom/1)
    |> convert_field(:format, &to_existing_atom/1)
  end

  defp normalize_dataset_name(val) when is_binary(val) do
    if String.match?(val, ~r/^[a-z_][a-z0-9_]*$/) do
      safe_existing_atom_or_value(val)
    else
      val
    end
  end

  defp normalize_dataset_name(val), do: to_existing_atom(val)

  defp safe_existing_atom_or_value(value) do
    case safe_existing_atom(value) do
      {:ok, atom} -> atom
      :error -> value
    end
  end

  defp convert_output_spec_fields(attrs) do
    attrs
    |> convert_field(:name, &to_existing_atom/1)
    |> convert_field(:formats, fn list -> Enum.map(list, &to_existing_atom/1) end)
    |> convert_field(:sink, &to_existing_atom/1)
  end

  defp convert_reliability_config_fields(attrs) do
    attrs
    |> convert_field(:ensemble, fn map -> from_map!(map, Ensemble) end)
    |> convert_field(:hedging, fn map -> from_map!(map, Hedging) end)
    |> convert_field(:guardrails, fn map -> from_map!(map, Guardrail) end)
    |> convert_field(:stats, fn map -> from_map!(map, Stats) end)
    |> convert_field(:fairness, fn map -> from_map!(map, Fairness) end)
    |> convert_field(:feedback, fn
      %{} = map -> from_map!(map, Feedback.Config)
      value -> value
    end)
  end

  defp convert_ensemble_fields(attrs) do
    attrs
    |> convert_field(:strategy, &to_existing_atom/1)
    |> convert_field(:execution_mode, &to_existing_atom/1)
    |> convert_field(:models, fn list -> Enum.map(list, &to_existing_atom/1) end)
    |> convert_field(:weights, &convert_map_keys_to_existing_atoms/1)
  end

  defp convert_hedging_fields(attrs) do
    attrs
    |> convert_field(:strategy, &to_existing_atom/1)
  end

  defp convert_stats_fields(attrs) do
    attrs
    |> convert_field(:tests, fn list -> Enum.map(list, &to_existing_atom/1) end)
    |> convert_field(:effect_size_type, &to_existing_atom/1)
    |> convert_field(:multiple_testing_correction, &to_existing_atom/1)
  end

  defp convert_fairness_fields(attrs) do
    attrs
    |> convert_field(:metrics, fn list -> Enum.map(list, &to_existing_atom/1) end)
    |> convert_field(:group_by, &to_existing_atom/1)
  end

  defp convert_guardrail_fields(attrs) do
    attrs
    |> convert_field(:profiles, fn list -> Enum.map(list, &to_existing_atom/1) end)
  end

  defp convert_field(attrs, field, converter) when is_map(attrs) do
    case Map.get(attrs, field) do
      nil -> attrs
      value -> Map.put(attrs, field, converter.(value))
    end
  end

  defp convert_map_keys_to_existing_atoms(value) when is_map(value) do
    Enum.reduce(value, %{}, fn {key, map_value}, acc ->
      converted_key = to_existing_atom(key)
      Map.put(acc, converted_key, map_value)
    end)
  end

  defp convert_map_keys_to_existing_atoms(value), do: value

  defp try_from_map(fun) when is_function(fun, 0) do
    {:ok, fun.()}
  rescue
    e -> {:error, e}
  end

  defp to_existing_atom(value) when is_atom(value), do: value

  defp to_existing_atom(value) when is_binary(value) do
    case safe_existing_atom(value) do
      {:ok, atom} -> atom
      :error -> value
    end
  end

  defp to_existing_atom(value), do: value

  defp safe_existing_atom(value) when is_binary(value) do
    {:ok, String.to_existing_atom(value)}
  rescue
    ArgumentError -> :error
  end

  defp parse_datetime(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, dt, _offset} -> dt
      _ -> value
    end
  end

  defp parse_datetime(value), do: value

  defp from_map!(map, type) do
    case from_map(map, type) do
      {:ok, struct} -> struct
      {:error, e} -> raise e
    end
  end

  defp convert_model_ref_fields(attrs) do
    attrs
    |> convert_field(:id, &to_existing_atom/1)
    |> convert_field(:provider, &to_existing_atom/1)
    |> convert_field(:framework, &to_existing_atom/1)
    |> convert_field(:architecture, &to_existing_atom/1)
    |> convert_field(:task, &to_existing_atom/1)
  end

  defp convert_model_version_fields(attrs) do
    attrs
    |> convert_field(:id, &to_existing_atom/1)
    |> convert_field(:model_id, &to_existing_atom/1)
    |> convert_field(:stage, &to_existing_atom/1)
    |> convert_field(:training_run_id, &to_existing_atom/1)
    |> convert_field(:created_at, &parse_datetime/1)
  end

  defp convert_training_config_fields(attrs) do
    attrs
    |> convert_field(:id, &to_existing_atom/1)
    |> convert_field(:model_ref, fn map -> from_map!(map, ModelRef) end)
    |> convert_field(:dataset_ref, fn map -> from_map!(map, DatasetRef) end)
    |> convert_field(:optimizer, &to_existing_atom/1)
    |> convert_field(:loss_function, &to_existing_atom/1)
    |> convert_field(:device, &to_existing_atom/1)
    |> convert_field(:metrics, fn list -> Enum.map(list, &to_existing_atom/1) end)
  end

  defp convert_training_run_fields(attrs) do
    attrs
    |> convert_field(:id, &to_existing_atom/1)
    |> convert_field(:config, fn map -> from_map!(map, Training.Config) end)
    |> convert_field(:status, &to_existing_atom/1)
    |> convert_field(:final_model_version, &to_existing_atom/1)
    |> convert_field(:started_at, &parse_datetime/1)
    |> convert_field(:completed_at, &parse_datetime/1)
  end

  defp convert_deployment_config_fields(attrs) do
    attrs
    |> convert_field(:id, &to_existing_atom/1)
    |> convert_field(:model_version_id, &to_existing_atom/1)
    |> convert_field(:environment, &to_existing_atom/1)
    |> convert_field(:strategy, &to_existing_atom/1)
  end

  defp convert_deployment_status_fields(attrs) do
    attrs
    |> convert_field(:id, &to_existing_atom/1)
    |> convert_field(:deployment_id, &to_existing_atom/1)
    |> convert_field(:state, &to_existing_atom/1)
    |> convert_field(:health, &to_existing_atom/1)
    |> convert_field(:last_health_check, &parse_datetime/1)
    |> convert_field(:created_at, &parse_datetime/1)
    |> convert_field(:updated_at, &parse_datetime/1)
  end

  defp convert_feedback_event_fields(attrs) do
    attrs
    |> convert_field(:deployment_id, &to_existing_atom/1)
    |> convert_field(:feedback_type, &to_existing_atom/1)
    |> convert_field(:timestamp, &parse_datetime/1)
  end

  defp convert_feedback_config_fields(attrs) do
    attrs
    |> convert_field(:storage, &to_existing_atom/1)
    |> convert_field(:feedback_types, fn list -> Enum.map(list, &to_existing_atom/1) end)
  end
end
