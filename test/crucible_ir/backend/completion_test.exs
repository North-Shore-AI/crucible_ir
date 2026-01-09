defmodule CrucibleIR.Backend.CompletionTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.Backend.Completion
  alias CrucibleIR.Validation

  describe "struct defaults" do
    test "uses expected defaults" do
      completion = %Completion{}

      assert completion.choices == []
      assert completion.model == nil
      assert completion.usage == nil
      assert completion.latency_ms == nil
      assert completion.time_to_first_token_ms == nil
      assert completion.request_id == nil
      assert completion.trace_id == nil
      assert completion.raw_response == nil
      assert completion.metadata == %{}
    end
  end

  describe "Jason encoding" do
    test "encodes completion to JSON" do
      completion = %Completion{
        model: "gpt-4o",
        choices: [
          %{index: 0, message: %{role: :assistant, content: "Hi"}, finish_reason: :stop}
        ]
      }

      {:ok, json} = Jason.encode(completion)

      assert json =~ "gpt-4o"
      assert json =~ "Hi"
      assert json =~ "stop"
    end
  end

  describe "validation" do
    test "accepts a valid completion" do
      completion = %Completion{
        model: "gpt-4o",
        choices: [
          %{index: 0, message: %{role: :assistant, content: "Hi"}, finish_reason: :stop}
        ]
      }

      assert {:ok, ^completion} = Validation.validate(completion)
    end

    test "rejects non-list choices" do
      completion = %Completion{choices: "nope"}

      assert {:error, errors} = Validation.validate(completion)
      assert "choices must be a list" in errors
    end

    test "rejects invalid finish_reason" do
      completion = %Completion{
        choices: [
          %{index: 0, message: %{role: :assistant, content: "Hi"}, finish_reason: :invalid}
        ]
      }

      assert {:error, errors} = Validation.validate(completion)

      assert "choices[0].finish_reason must be one of: stop, length, tool_calls, content_filter, error" in errors
    end
  end
end
