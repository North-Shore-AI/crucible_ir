defmodule CrucibleIR.ModelRefTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.ModelRef

  describe "struct creation" do
    test "creates with required id field" do
      ref = %ModelRef{id: :gpt2_base}
      assert ref.id == :gpt2_base
    end

    test "uses correct defaults" do
      ref = %ModelRef{id: :gpt2_base}

      assert ref.provider == :local
      assert ref.framework == :nx
      assert ref.name == nil
      assert ref.version == nil
      assert ref.artifact_uri == nil
      assert ref.architecture == nil
      assert ref.task == nil
      assert ref.metadata == nil
      assert ref.options == nil
    end

    test "accepts all optional fields" do
      ref = %ModelRef{
        id: :gpt2_base,
        name: "GPT-2 Base Model",
        version: "1.0.0",
        provider: :huggingface,
        framework: :pytorch,
        architecture: :transformer,
        task: :text_generation,
        artifact_uri: "s3://models/gpt2",
        metadata: %{author: "OpenAI"},
        options: %{quantized: true}
      }

      assert ref.id == :gpt2_base
      assert ref.name == "GPT-2 Base Model"
      assert ref.version == "1.0.0"
      assert ref.provider == :huggingface
      assert ref.framework == :pytorch
      assert ref.architecture == :transformer
      assert ref.task == :text_generation
      assert ref.artifact_uri == "s3://models/gpt2"
      assert ref.metadata == %{author: "OpenAI"}
      assert ref.options == %{quantized: true}
    end

    test "accepts string id" do
      ref = %ModelRef{id: "custom-model-v1"}
      assert ref.id == "custom-model-v1"
    end
  end

  describe "providers" do
    test "supports local provider" do
      ref = %ModelRef{id: :model, provider: :local}
      assert ref.provider == :local
    end

    test "supports huggingface provider" do
      ref = %ModelRef{id: :model, provider: :huggingface}
      assert ref.provider == :huggingface
    end

    test "supports openai provider" do
      ref = %ModelRef{id: :model, provider: :openai}
      assert ref.provider == :openai
    end

    test "supports anthropic provider" do
      ref = %ModelRef{id: :model, provider: :anthropic}
      assert ref.provider == :anthropic
    end

    test "supports s3 provider" do
      ref = %ModelRef{id: :model, provider: :s3}
      assert ref.provider == :s3
    end

    test "supports gcs provider" do
      ref = %ModelRef{id: :model, provider: :gcs}
      assert ref.provider == :gcs
    end
  end

  describe "frameworks" do
    test "supports nx framework" do
      ref = %ModelRef{id: :model, framework: :nx}
      assert ref.framework == :nx
    end

    test "supports pytorch framework" do
      ref = %ModelRef{id: :model, framework: :pytorch}
      assert ref.framework == :pytorch
    end

    test "supports tensorflow framework" do
      ref = %ModelRef{id: :model, framework: :tensorflow}
      assert ref.framework == :tensorflow
    end

    test "supports onnx framework" do
      ref = %ModelRef{id: :model, framework: :onnx}
      assert ref.framework == :onnx
    end

    test "supports safetensors framework" do
      ref = %ModelRef{id: :model, framework: :safetensors}
      assert ref.framework == :safetensors
    end
  end

  describe "tasks" do
    test "supports text_classification task" do
      ref = %ModelRef{id: :model, task: :text_classification}
      assert ref.task == :text_classification
    end

    test "supports text_generation task" do
      ref = %ModelRef{id: :model, task: :text_generation}
      assert ref.task == :text_generation
    end

    test "supports embedding task" do
      ref = %ModelRef{id: :model, task: :embedding}
      assert ref.task == :embedding
    end

    test "supports qa task" do
      ref = %ModelRef{id: :model, task: :qa}
      assert ref.task == :qa
    end

    test "supports summarization task" do
      ref = %ModelRef{id: :model, task: :summarization}
      assert ref.task == :summarization
    end
  end

  describe "architectures" do
    test "supports transformer architecture" do
      ref = %ModelRef{id: :model, architecture: :transformer}
      assert ref.architecture == :transformer
    end

    test "supports lstm architecture" do
      ref = %ModelRef{id: :model, architecture: :lstm}
      assert ref.architecture == :lstm
    end

    test "supports cnn architecture" do
      ref = %ModelRef{id: :model, architecture: :cnn}
      assert ref.architecture == :cnn
    end

    test "supports mlp architecture" do
      ref = %ModelRef{id: :model, architecture: :mlp}
      assert ref.architecture == :mlp
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      ref = %ModelRef{id: :gpt2_base, provider: :huggingface}
      json = Jason.encode!(ref)

      assert is_binary(json)
      assert json =~ "gpt2_base"
      assert json =~ "huggingface"
    end

    test "encodes all fields" do
      ref = %ModelRef{
        id: :gpt2,
        name: "GPT-2",
        version: "1.0.0",
        provider: :huggingface,
        framework: :pytorch
      }

      json = Jason.encode!(ref)

      assert json =~ "gpt2"
      assert json =~ "GPT-2"
      assert json =~ "1.0.0"
      assert json =~ "huggingface"
      assert json =~ "pytorch"
    end
  end
end
