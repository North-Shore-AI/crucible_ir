defmodule CrucibleIR.Training.ConfigTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.Training.Config
  alias CrucibleIR.{ModelRef, DatasetRef}

  describe "struct creation" do
    test "creates with required fields" do
      config = %Config{
        id: :train_gpt2,
        model_ref: %ModelRef{id: :gpt2},
        dataset_ref: %DatasetRef{name: :wikitext}
      }

      assert config.id == :train_gpt2
      assert config.model_ref.id == :gpt2
      assert config.dataset_ref.name == :wikitext
    end

    test "uses correct defaults" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data}
      }

      assert config.epochs == 1
      assert config.batch_size == 32
      assert config.learning_rate == 0.001
      assert config.optimizer == :adam
      assert config.loss_function == :cross_entropy
      assert config.metrics == [:loss, :accuracy]
      assert config.device == :cpu
      assert config.mixed_precision == false
      assert config.validation_split == nil
      assert config.seed == nil
      assert config.gradient_clipping == nil
      assert config.early_stopping == nil
      assert config.checkpoint_every == nil
      assert config.options == nil
    end

    test "accepts all optional fields" do
      config = %Config{
        id: :train_gpt2,
        model_ref: %ModelRef{id: :gpt2},
        dataset_ref: %DatasetRef{name: :wikitext},
        epochs: 10,
        batch_size: 64,
        learning_rate: 0.0001,
        optimizer: :adamw,
        loss_function: :mse,
        metrics: [:loss, :accuracy, :f1],
        validation_split: 0.2,
        device: :cuda,
        seed: 42,
        mixed_precision: true,
        gradient_clipping: 1.0,
        early_stopping: %{patience: 5, min_delta: 0.001},
        checkpoint_every: 1000,
        options: %{warmup_steps: 100}
      }

      assert config.epochs == 10
      assert config.batch_size == 64
      assert config.learning_rate == 0.0001
      assert config.optimizer == :adamw
      assert config.loss_function == :mse
      assert config.metrics == [:loss, :accuracy, :f1]
      assert config.validation_split == 0.2
      assert config.device == :cuda
      assert config.seed == 42
      assert config.mixed_precision == true
      assert config.gradient_clipping == 1.0
      assert config.early_stopping == %{patience: 5, min_delta: 0.001}
      assert config.checkpoint_every == 1000
      assert config.options == %{warmup_steps: 100}
    end
  end

  describe "optimizers" do
    test "supports adam optimizer" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        optimizer: :adam
      }

      assert config.optimizer == :adam
    end

    test "supports sgd optimizer" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        optimizer: :sgd
      }

      assert config.optimizer == :sgd
    end

    test "supports adamw optimizer" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        optimizer: :adamw
      }

      assert config.optimizer == :adamw
    end

    test "supports rmsprop optimizer" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        optimizer: :rmsprop
      }

      assert config.optimizer == :rmsprop
    end
  end

  describe "loss functions" do
    test "supports cross_entropy loss" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        loss_function: :cross_entropy
      }

      assert config.loss_function == :cross_entropy
    end

    test "supports mse loss" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        loss_function: :mse
      }

      assert config.loss_function == :mse
    end

    test "supports mae loss" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        loss_function: :mae
      }

      assert config.loss_function == :mae
    end

    test "supports bce loss" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        loss_function: :bce
      }

      assert config.loss_function == :bce
    end
  end

  describe "devices" do
    test "supports cpu device" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        device: :cpu
      }

      assert config.device == :cpu
    end

    test "supports cuda device" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        device: :cuda
      }

      assert config.device == :cuda
    end

    test "supports mps device" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        device: :mps
      }

      assert config.device == :mps
    end

    test "supports tpu device" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model},
        dataset_ref: %DatasetRef{name: :data},
        device: :tpu
      }

      assert config.device == :tpu
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      config = %Config{
        id: :train_gpt2,
        model_ref: %ModelRef{id: :gpt2},
        dataset_ref: %DatasetRef{name: :wikitext},
        epochs: 10,
        batch_size: 32
      }

      json = Jason.encode!(config)

      assert is_binary(json)
      assert json =~ "train_gpt2"
      assert json =~ "gpt2"
      assert json =~ "wikitext"
    end

    test "encodes nested structs" do
      config = %Config{
        id: :train,
        model_ref: %ModelRef{id: :model, provider: :huggingface},
        dataset_ref: %DatasetRef{name: :data, split: :train}
      }

      json = Jason.encode!(config)

      assert json =~ "huggingface"
      assert json =~ "train"
    end
  end
end
