defmodule CrucibleIR.BackendRefTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.BackendRef

  describe "struct creation" do
    test "creates with required id field" do
      ref = %BackendRef{id: :openai_gpt4}
      assert ref.id == :openai_gpt4
    end

    test "sets default profile to :default" do
      ref = %BackendRef{id: :openai_gpt4}
      assert ref.profile == :default
    end

    test "allows custom profile" do
      ref = %BackendRef{id: :openai_gpt4, profile: :fast}
      assert ref.profile == :fast
    end

    test "accepts options" do
      ref = %BackendRef{id: :anthropic_claude, options: %{temperature: 0.7}}
      assert ref.options == %{temperature: 0.7}
    end

    test "options default to nil" do
      ref = %BackendRef{id: :openai_gpt4}
      assert ref.options == nil
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      ref = %BackendRef{id: :openai_gpt4, profile: :fast}
      {:ok, json} = Jason.encode(ref)
      assert json =~ "openai_gpt4"
      assert json =~ "fast"
    end

    test "encodes with options" do
      ref = %BackendRef{id: :anthropic_claude, options: %{max_tokens: 1000}}
      {:ok, json} = Jason.encode(ref)
      {:ok, decoded} = Jason.decode(json)
      assert decoded["options"]["max_tokens"] == 1000
    end
  end
end
