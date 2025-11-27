defmodule CrucibleIR.StageDefTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.StageDef

  describe "struct creation" do
    test "creates with required name field" do
      stage = %StageDef{name: :preprocessing}
      assert stage.name == :preprocessing
    end

    test "sets default enabled to true" do
      stage = %StageDef{name: :preprocessing}
      assert stage.enabled == true
    end

    test "allows disabling a stage" do
      stage = %StageDef{name: :preprocessing, enabled: false}
      assert stage.enabled == false
    end

    test "accepts module" do
      stage = %StageDef{name: :preprocessing, module: MyApp.Preprocessor}
      assert stage.module == MyApp.Preprocessor
    end

    test "accepts options" do
      stage = %StageDef{name: :preprocessing, options: %{normalize: true}}
      assert stage.options == %{normalize: true}
    end

    test "module defaults to nil" do
      stage = %StageDef{name: :preprocessing}
      assert stage.module == nil
    end

    test "options default to nil" do
      stage = %StageDef{name: :preprocessing}
      assert stage.options == nil
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      stage = %StageDef{name: :preprocessing, enabled: true}
      {:ok, json} = Jason.encode(stage)
      assert json =~ "preprocessing"
      assert json =~ "true"
    end

    test "encodes with all fields" do
      stage = %StageDef{
        name: :preprocessing,
        module: MyApp.Preprocessor,
        enabled: false,
        options: %{normalize: true}
      }

      {:ok, json} = Jason.encode(stage)
      {:ok, decoded} = Jason.decode(json)
      assert decoded["enabled"] == false
      assert decoded["options"]["normalize"] == true
    end
  end
end
