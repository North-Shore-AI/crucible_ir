defmodule CrucibleIR.Backend.PromptTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.Backend.{Options, Prompt}
  alias CrucibleIR.Validation

  describe "struct defaults" do
    test "uses expected defaults" do
      prompt = %Prompt{}

      assert prompt.messages == []
      assert prompt.system == nil
      assert prompt.tools == nil
      assert prompt.tool_choice == nil
      assert %Options{} = prompt.options
      assert prompt.request_id == nil
      assert prompt.trace_id == nil
      assert prompt.metadata == %{}
    end
  end

  describe "Jason encoding" do
    test "encodes prompt to JSON" do
      prompt = %Prompt{
        messages: [%{role: :user, content: "Hello"}],
        options: %Options{model: "gpt-4o"}
      }

      {:ok, json} = Jason.encode(prompt)

      assert json =~ "messages"
      assert json =~ "Hello"
      assert json =~ "gpt-4o"
    end
  end

  describe "validation" do
    test "accepts a valid prompt" do
      prompt = %Prompt{messages: [%{role: :user, content: "Hello"}]}

      assert {:ok, ^prompt} = Validation.validate(prompt)
    end

    test "rejects non-list messages" do
      prompt = %Prompt{messages: "nope"}

      assert {:error, errors} = Validation.validate(prompt)
      assert "messages must be a list" in errors
    end

    test "rejects invalid message role" do
      prompt = %Prompt{messages: [%{role: :invalid, content: "Hello"}]}

      assert {:error, errors} = Validation.validate(prompt)
      assert "messages[0].role must be one of: system, user, assistant, tool" in errors
    end

    test "rejects invalid tool_choice" do
      prompt = %Prompt{messages: [%{role: :user, content: "Hi"}], tool_choice: :sometimes}

      assert {:error, errors} = Validation.validate(prompt)
      assert "tool_choice must be one of: auto, none, required, or %{name: string}" in errors
    end
  end
end
