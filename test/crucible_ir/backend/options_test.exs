defmodule CrucibleIR.Backend.OptionsTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.Backend.Options
  alias CrucibleIR.Validation

  describe "struct defaults" do
    test "uses expected defaults" do
      options = %Options{}

      assert options.model == nil
      assert options.temperature == nil
      assert options.max_tokens == nil
      assert options.top_p == nil
      assert options.top_k == nil
      assert options.frequency_penalty == nil
      assert options.presence_penalty == nil
      assert options.stop == nil
      assert options.response_format == nil
      assert options.json_schema == nil
      assert options.stream == false
      assert options.cache_control == nil
      assert options.extended_thinking == false
      assert options.thinking_budget_tokens == nil
      assert options.seed == nil
      assert options.timeout_ms == nil
      assert options.extra == %{}
    end
  end

  describe "Jason encoding" do
    test "encodes options to JSON" do
      options = %Options{model: "gpt-4o", temperature: 0.2, stream: true}
      {:ok, json} = Jason.encode(options)

      assert json =~ "gpt-4o"
      assert json =~ "0.2"
      assert json =~ "true"
    end
  end

  describe "validation" do
    test "accepts default options" do
      options = %Options{}

      assert {:ok, ^options} = Validation.validate(options)
    end

    test "rejects invalid response_format" do
      options = %Options{response_format: :xml}

      assert {:error, errors} = Validation.validate(options)
      assert "response_format must be one of: text, json, json_schema" in errors
    end

    test "rejects negative max_tokens" do
      options = %Options{max_tokens: -1}

      assert {:error, errors} = Validation.validate(options)
      assert "max_tokens must be a non-negative integer" in errors
    end

    test "rejects json_schema response_format without schema" do
      options = %Options{response_format: :json_schema, json_schema: nil}

      assert {:error, errors} = Validation.validate(options)
      assert "json_schema is required when response_format is json_schema" in errors
    end
  end
end
