defmodule CrucibleIR.StageDef do
  @moduledoc """
  Definition of a processing stage in an experiment pipeline.

  A `StageDef` describes a step in the experiment pipeline, which can be
  enabled or disabled, and may have associated configuration options.

  ## Fields

  - `:name` - The stage name/identifier (required)
  - `:module` - The module implementing this stage
  - `:options` - Stage-specific configuration options
  - `:enabled` - Whether this stage is active (default: `true`)

  `:options` is an opaque map. CrucibleIR does not validate or coerce it; stage
  implementations in domain packages own option validation.

  ## Examples

      iex> stage = %CrucibleIR.StageDef{name: :preprocessing}
      iex> stage.enabled
      true

      iex> stage = %CrucibleIR.StageDef{name: :preprocessing, enabled: false}
      iex> stage.enabled
      false

      iex> stage = %CrucibleIR.StageDef{name: :preprocessing, module: MyApp.Preprocessor, options: %{normalize: true}}
      iex> stage.options
      %{normalize: true}
  """

  @derive Jason.Encoder
  @enforce_keys [:name]
  defstruct [
    :name,
    :module,
    :options,
    enabled: true
  ]

  @type t :: %__MODULE__{
          name: atom(),
          module: module() | nil,
          options: map() | nil,
          enabled: boolean()
        }
end
