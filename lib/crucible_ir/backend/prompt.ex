defmodule CrucibleIR.Backend.Prompt do
  @moduledoc """
  Universal prompt IR for backend requests.

  Supports chat-style messages, tool calling, and multimodal content in a
  provider-agnostic shape.

  ## Fields

  - `:messages` - Message history
  - `:system` - System prompt (optional)
  - `:tools` - Tool definitions (optional)
  - `:tool_choice` - Tool selection directive
  - `:options` - Backend options
  - `:request_id` - Request correlation ID
  - `:trace_id` - Trace correlation ID
  - `:metadata` - Additional metadata

  ## Examples

      iex> %CrucibleIR.Backend.Prompt{messages: [%{role: :user, content: "Hello"}]}
  """

  alias CrucibleIR.Backend.Options

  @type role :: :system | :user | :assistant | :tool

  @type content_part ::
          %{type: :text, text: String.t()}
          | %{type: :image, url: String.t(), media_type: String.t() | nil}
          | %{type: :image, base64: String.t(), media_type: String.t()}
          | %{type: :audio, url: String.t(), format: String.t()}
          | %{type: :tool_result, tool_call_id: String.t(), content: String.t()}

  @type tool_call :: %{
          id: String.t(),
          name: String.t(),
          arguments: map() | String.t()
        }

  @type message :: %{
          role: role(),
          content: String.t() | [content_part()],
          name: String.t() | nil,
          tool_calls: [tool_call()] | nil,
          tool_call_id: String.t() | nil
        }

  @type tool_choice :: :auto | :none | :required | %{name: String.t()}
  @type tool :: map()

  @derive Jason.Encoder
  defstruct messages: [],
            system: nil,
            tools: nil,
            tool_choice: nil,
            options: %Options{},
            request_id: nil,
            trace_id: nil,
            metadata: %{}

  @type t :: %__MODULE__{
          messages: [message()],
          system: String.t() | nil,
          tools: [tool()] | nil,
          tool_choice: tool_choice() | nil,
          options: Options.t(),
          request_id: String.t() | nil,
          trace_id: String.t() | nil,
          metadata: map()
        }
end
