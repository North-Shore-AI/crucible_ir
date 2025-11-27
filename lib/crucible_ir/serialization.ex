defmodule CrucibleIR.Serialization do
  @moduledoc """
  JSON serialization and deserialization for IR structs.

  This module provides functions to convert CrucibleIR structs to and from
  JSON, enabling persistence, transport, and interoperability with other systems.

  ## Functions

  - `to_json/1` - Encode struct to JSON string
  - `from_json/2` - Decode JSON string to struct of given type
  - `from_map/2` - Convert plain map to struct

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

  alias CrucibleIR.{Experiment, BackendRef, StageDef, DatasetRef, OutputSpec}
  alias CrucibleIR.Reliability.{Config, Ensemble, Hedging, Stats, Fairness, Guardrail}

  @experiment_fields ~w(id backend pipeline description owner tags metadata dataset reliability outputs created_at updated_at)a
  @backend_ref_fields ~w(id profile options)a
  @stage_def_fields ~w(name module options enabled)a
  @dataset_ref_fields ~w(name provider split options)a
  @output_spec_fields ~w(name formats sink options)a
  @config_fields ~w(ensemble hedging guardrails stats fairness)a
  @ensemble_fields ~w(strategy execution_mode models weights min_agreement timeout_ms options)a
  @hedging_fields ~w(strategy delay_ms percentile max_hedges budget_percent options)a
  @stats_fields ~w(tests alpha confidence_level effect_size_type multiple_testing_correction bootstrap_iterations options)a
  @fairness_fields ~w(enabled metrics group_by threshold fail_on_violation options)a
  @guardrail_fields ~w(profiles prompt_injection_detection jailbreak_detection pii_detection pii_redaction content_moderation fail_on_detection options)a

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
    try do
      attrs =
        map
        |> atomize_keys(@experiment_fields)
        |> convert_experiment_fields()

      {:ok, struct!(Experiment, attrs)}
    rescue
      e -> {:error, e}
    end
  end

  def from_map(map, BackendRef) when is_map(map) do
    try do
      attrs =
        map
        |> atomize_keys(@backend_ref_fields)
        |> convert_backend_ref_fields()

      {:ok, struct!(BackendRef, attrs)}
    rescue
      e -> {:error, e}
    end
  end

  def from_map(map, StageDef) when is_map(map) do
    try do
      attrs =
        map
        |> atomize_keys(@stage_def_fields)
        |> convert_stage_def_fields()

      {:ok, struct!(StageDef, attrs)}
    rescue
      e -> {:error, e}
    end
  end

  def from_map(map, DatasetRef) when is_map(map) do
    try do
      attrs =
        map
        |> atomize_keys(@dataset_ref_fields)
        |> convert_dataset_ref_fields()

      {:ok, struct!(DatasetRef, attrs)}
    rescue
      e -> {:error, e}
    end
  end

  def from_map(map, OutputSpec) when is_map(map) do
    try do
      attrs =
        map
        |> atomize_keys(@output_spec_fields)
        |> convert_output_spec_fields()

      {:ok, struct!(OutputSpec, attrs)}
    rescue
      e -> {:error, e}
    end
  end

  def from_map(map, Config) when is_map(map) do
    try do
      attrs =
        map
        |> atomize_keys(@config_fields)
        |> convert_reliability_config_fields()

      {:ok, struct!(Config, attrs)}
    rescue
      e -> {:error, e}
    end
  end

  def from_map(map, Ensemble) when is_map(map) do
    try do
      attrs =
        map
        |> atomize_keys(@ensemble_fields)
        |> convert_ensemble_fields()

      {:ok, struct!(Ensemble, attrs)}
    rescue
      e -> {:error, e}
    end
  end

  def from_map(map, Hedging) when is_map(map) do
    try do
      attrs =
        map
        |> atomize_keys(@hedging_fields)
        |> convert_hedging_fields()

      {:ok, struct!(Hedging, attrs)}
    rescue
      e -> {:error, e}
    end
  end

  def from_map(map, Stats) when is_map(map) do
    try do
      attrs =
        map
        |> atomize_keys(@stats_fields)
        |> convert_stats_fields()

      {:ok, struct!(Stats, attrs)}
    rescue
      e -> {:error, e}
    end
  end

  def from_map(map, Fairness) when is_map(map) do
    try do
      attrs =
        map
        |> atomize_keys(@fairness_fields)
        |> convert_fairness_fields()

      {:ok, struct!(Fairness, attrs)}
    rescue
      e -> {:error, e}
    end
  end

  def from_map(map, Guardrail) when is_map(map) do
    try do
      attrs =
        map
        |> atomize_keys(@guardrail_fields)
        |> convert_guardrail_fields()

      {:ok, struct!(Guardrail, attrs)}
    rescue
      e -> {:error, e}
    end
  end

  # Private helper functions

  defp atomize_keys(map, allowed_fields) when is_map(map) do
    allowed_strings = MapSet.new(allowed_fields, &Atom.to_string/1)

    Enum.reduce(map, %{}, fn {k, v}, acc ->
      cond do
        is_atom(k) and k in allowed_fields ->
          Map.put(acc, k, v)

        is_binary(k) and MapSet.member?(allowed_strings, k) ->
          case safe_existing_atom(k) do
            {:ok, atom} -> Map.put(acc, atom, v)
            :error -> acc
          end

        true ->
          acc
      end
    end)
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
    |> convert_field(:tags, fn list -> Enum.map(list, &to_existing_atom/1) end)
    |> convert_field(:created_at, &parse_datetime/1)
    |> convert_field(:updated_at, &parse_datetime/1)
  end

  defp convert_backend_ref_fields(attrs) do
    attrs
    |> convert_field(:id, &to_existing_atom/1)
    |> convert_field(:profile, &to_existing_atom/1)
  end

  defp convert_stage_def_fields(attrs) do
    attrs
    |> convert_field(:name, &to_existing_atom/1)
  end

  defp convert_dataset_ref_fields(attrs) do
    attrs
    |> convert_field(:name, fn
      val when is_binary(val) ->
        # Keep as string if it doesn't look like an atom identifier
        if String.match?(val, ~r/^[a-z_][a-z0-9_]*$/) do
          case safe_existing_atom(val) do
            {:ok, atom} -> atom
            :error -> val
          end
        else
          val
        end

      val ->
        to_existing_atom(val)
    end)
    |> convert_field(:provider, &to_existing_atom/1)
    |> convert_field(:split, &to_existing_atom/1)
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
  end

  defp convert_ensemble_fields(attrs) do
    attrs
    |> convert_field(:strategy, &to_existing_atom/1)
    |> convert_field(:execution_mode, &to_existing_atom/1)
    |> convert_field(:models, fn list -> Enum.map(list, &to_existing_atom/1) end)
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
end
