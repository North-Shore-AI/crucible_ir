defmodule CrucibleIR.OutputSpec do
  @moduledoc """
  Specification for experiment output/reporting.

  An `OutputSpec` defines how and where experiment results should be output,
  including the output format(s) and destination.

  ## Fields

  - `:name` - The output name/identifier (required)
  - `:formats` - List of output formats (default: `[:markdown]`)
  - `:sink` - The output destination (default: `:file`)
  - `:options` - Output-specific configuration options

  ## Examples

      iex> spec = %CrucibleIR.OutputSpec{name: :results}
      iex> spec.formats
      [:markdown]

      iex> spec = %CrucibleIR.OutputSpec{name: :results, formats: [:json, :html], sink: :stdout}
      iex> spec.sink
      :stdout

      iex> spec = %CrucibleIR.OutputSpec{name: :results, options: %{path: "/tmp/results"}}
      iex> spec.options
      %{path: "/tmp/results"}
  """

  @derive Jason.Encoder
  @enforce_keys [:name]
  defstruct [
    :name,
    :options,
    formats: [:markdown],
    sink: :file
  ]

  @type format :: :markdown | :json | :html | :latex | :csv | atom()
  @type sink :: :file | :stdout | :s3 | :postgres | atom()

  @type t :: %__MODULE__{
          name: atom(),
          formats: [format()],
          sink: sink(),
          options: map() | nil
        }
end
