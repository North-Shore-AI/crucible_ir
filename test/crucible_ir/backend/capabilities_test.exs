defmodule CrucibleIR.Backend.CapabilitiesTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.Backend.Capabilities
  alias CrucibleIR.Validation

  describe "struct defaults" do
    test "uses expected defaults" do
      caps = %Capabilities{backend_id: :openai, provider: "openai"}

      assert caps.models == []
      assert caps.default_model == nil
      assert caps.supports_streaming == true
      assert caps.supports_tools == true
      assert caps.supports_vision == false
      assert caps.supports_audio == false
      assert caps.supports_json_mode == true
      assert caps.supports_extended_thinking == false
      assert caps.supports_caching == false
      assert caps.max_tokens == nil
      assert caps.max_context_length == nil
      assert caps.max_images_per_request == nil
      assert caps.requests_per_minute == nil
      assert caps.tokens_per_minute == nil
      assert caps.cost_per_million_input == nil
      assert caps.cost_per_million_output == nil
      assert caps.metadata == %{}
    end
  end

  describe "Jason encoding" do
    test "encodes capabilities to JSON" do
      caps = %Capabilities{backend_id: :openai, provider: "openai", models: ["gpt-4o"]}
      {:ok, json} = Jason.encode(caps)

      assert json =~ "openai"
      assert json =~ "gpt-4o"
    end
  end

  describe "validation" do
    test "accepts valid capabilities" do
      caps = %Capabilities{backend_id: :openai, provider: "openai"}

      assert {:ok, ^caps} = Validation.validate(caps)
    end

    test "rejects missing backend_id" do
      caps = %Capabilities{backend_id: nil, provider: "openai"}

      assert {:error, errors} = Validation.validate(caps)
      assert "backend_id is required" in errors
    end

    test "rejects invalid supports_streaming" do
      caps = %Capabilities{backend_id: :openai, provider: "openai", supports_streaming: "yes"}

      assert {:error, errors} = Validation.validate(caps)
      assert "supports_streaming must be a boolean" in errors
    end
  end
end
