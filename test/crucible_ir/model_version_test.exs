defmodule CrucibleIR.ModelVersionTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.ModelVersion

  describe "struct creation" do
    test "creates with required fields" do
      version = %ModelVersion{
        id: :v1_0_0,
        model_id: :gpt2_base,
        version: "1.0.0"
      }

      assert version.id == :v1_0_0
      assert version.model_id == :gpt2_base
      assert version.version == "1.0.0"
    end

    test "uses correct defaults" do
      version = %ModelVersion{
        id: :v1_0_0,
        model_id: :gpt2_base,
        version: "1.0.0"
      }

      assert version.stage == :development
      assert version.training_run_id == nil
      assert version.metrics == nil
      assert version.artifact_uri == nil
      assert version.parent_version == nil
      assert version.description == nil
      assert version.created_at == nil
      assert version.created_by == nil
      assert version.options == nil
    end

    test "accepts all optional fields" do
      now = DateTime.utc_now()

      version = %ModelVersion{
        id: :v1_0_0,
        model_id: :gpt2_base,
        version: "1.0.0",
        stage: :production,
        training_run_id: :run_001,
        metrics: %{accuracy: 0.95, loss: 0.05},
        artifact_uri: "s3://models/gpt2/v1.0.0",
        parent_version: "0.9.0",
        description: "First production release",
        created_at: now,
        created_by: "ml_team",
        options: %{quantized: true}
      }

      assert version.stage == :production
      assert version.training_run_id == :run_001
      assert version.metrics == %{accuracy: 0.95, loss: 0.05}
      assert version.artifact_uri == "s3://models/gpt2/v1.0.0"
      assert version.parent_version == "0.9.0"
      assert version.description == "First production release"
      assert version.created_at == now
      assert version.created_by == "ml_team"
      assert version.options == %{quantized: true}
    end

    test "accepts string model_id" do
      version = %ModelVersion{
        id: :v1,
        model_id: "custom-model",
        version: "1.0.0"
      }

      assert version.model_id == "custom-model"
    end
  end

  describe "stages" do
    test "supports development stage" do
      version = %ModelVersion{id: :v1, model_id: :model, version: "1.0.0", stage: :development}
      assert version.stage == :development
    end

    test "supports staging stage" do
      version = %ModelVersion{id: :v1, model_id: :model, version: "1.0.0", stage: :staging}
      assert version.stage == :staging
    end

    test "supports production stage" do
      version = %ModelVersion{id: :v1, model_id: :model, version: "1.0.0", stage: :production}
      assert version.stage == :production
    end

    test "supports archived stage" do
      version = %ModelVersion{id: :v1, model_id: :model, version: "1.0.0", stage: :archived}
      assert version.stage == :archived
    end
  end

  describe "versioning" do
    test "accepts semver format" do
      version = %ModelVersion{id: :v1, model_id: :model, version: "1.2.3"}
      assert version.version == "1.2.3"
    end

    test "accepts semver with prerelease" do
      version = %ModelVersion{id: :v1, model_id: :model, version: "1.0.0-beta.1"}
      assert version.version == "1.0.0-beta.1"
    end

    test "accepts semver with build metadata" do
      version = %ModelVersion{id: :v1, model_id: :model, version: "1.0.0+build.123"}
      assert version.version == "1.0.0+build.123"
    end
  end

  describe "lineage" do
    test "can track parent version" do
      version = %ModelVersion{
        id: :v1_1_0,
        model_id: :model,
        version: "1.1.0",
        parent_version: "1.0.0"
      }

      assert version.parent_version == "1.0.0"
    end

    test "can link to training run" do
      version = %ModelVersion{
        id: :v1,
        model_id: :model,
        version: "1.0.0",
        training_run_id: :training_run_123
      }

      assert version.training_run_id == :training_run_123
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      version = %ModelVersion{
        id: :v1_0_0,
        model_id: :gpt2_base,
        version: "1.0.0",
        stage: :production
      }

      json = Jason.encode!(version)

      assert is_binary(json)
      assert json =~ "v1_0_0"
      assert json =~ "gpt2_base"
      assert json =~ "1.0.0"
      assert json =~ "production"
    end

    test "encodes metrics" do
      version = %ModelVersion{
        id: :v1,
        model_id: :model,
        version: "1.0.0",
        metrics: %{accuracy: 0.95, f1: 0.92}
      }

      json = Jason.encode!(version)

      assert json =~ "accuracy"
      assert json =~ "0.95"
      assert json =~ "f1"
      assert json =~ "0.92"
    end
  end
end
