defmodule CrucibleIR.Training.RunTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.{DatasetRef, ModelRef}
  alias CrucibleIR.Training.{Config, Run}

  defp sample_config do
    %Config{
      id: :train_config,
      model_ref: %ModelRef{id: :gpt2},
      dataset_ref: %DatasetRef{name: :wikitext}
    }
  end

  describe "struct creation" do
    test "creates with required fields" do
      run = %Run{
        id: :run_001,
        config: sample_config()
      }

      assert run.id == :run_001
      assert run.config.id == :train_config
    end

    test "uses correct defaults" do
      run = %Run{
        id: :run_001,
        config: sample_config()
      }

      assert run.status == :pending
      assert run.current_epoch == nil
      assert run.metrics_history == nil
      assert run.best_metrics == nil
      assert run.checkpoint_uris == nil
      assert run.final_model_version == nil
      assert run.started_at == nil
      assert run.completed_at == nil
      assert run.error_message == nil
      assert run.options == nil
    end

    test "accepts all optional fields" do
      now = DateTime.utc_now()
      later = DateTime.add(now, 3600)

      run = %Run{
        id: :run_001,
        config: sample_config(),
        status: :completed,
        current_epoch: 10,
        metrics_history: [
          %{epoch: 1, loss: 2.5},
          %{epoch: 2, loss: 2.0}
        ],
        best_metrics: %{loss: 0.5, accuracy: 0.95},
        checkpoint_uris: ["s3://checkpoints/run_001/epoch_5", "s3://checkpoints/run_001/epoch_10"],
        final_model_version: :v1_0_0,
        started_at: now,
        completed_at: later,
        error_message: nil,
        options: %{distributed: true}
      }

      assert run.status == :completed
      assert run.current_epoch == 10
      assert length(run.metrics_history) == 2
      assert run.best_metrics.accuracy == 0.95
      assert length(run.checkpoint_uris) == 2
      assert run.final_model_version == :v1_0_0
      assert run.started_at == now
      assert run.completed_at == later
      assert run.options == %{distributed: true}
    end
  end

  describe "status" do
    test "supports pending status" do
      run = %Run{id: :run, config: sample_config(), status: :pending}
      assert run.status == :pending
    end

    test "supports running status" do
      run = %Run{id: :run, config: sample_config(), status: :running}
      assert run.status == :running
    end

    test "supports completed status" do
      run = %Run{id: :run, config: sample_config(), status: :completed}
      assert run.status == :completed
    end

    test "supports failed status" do
      run = %Run{
        id: :run,
        config: sample_config(),
        status: :failed,
        error_message: "Out of memory"
      }

      assert run.status == :failed
      assert run.error_message == "Out of memory"
    end

    test "supports cancelled status" do
      run = %Run{id: :run, config: sample_config(), status: :cancelled}
      assert run.status == :cancelled
    end
  end

  describe "metrics tracking" do
    test "tracks metrics history" do
      run = %Run{
        id: :run,
        config: sample_config(),
        metrics_history: [
          %{epoch: 1, loss: 2.5, accuracy: 0.6},
          %{epoch: 2, loss: 2.0, accuracy: 0.7},
          %{epoch: 3, loss: 1.5, accuracy: 0.8}
        ]
      }

      assert length(run.metrics_history) == 3
      assert hd(run.metrics_history).epoch == 1
    end

    test "tracks best metrics" do
      run = %Run{
        id: :run,
        config: sample_config(),
        best_metrics: %{loss: 0.5, accuracy: 0.95, f1: 0.92}
      }

      assert run.best_metrics.accuracy == 0.95
      assert run.best_metrics.f1 == 0.92
    end
  end

  describe "checkpoints" do
    test "tracks checkpoint URIs" do
      run = %Run{
        id: :run,
        config: sample_config(),
        checkpoint_uris: [
          "s3://models/run/checkpoint_1000",
          "s3://models/run/checkpoint_2000"
        ]
      }

      assert length(run.checkpoint_uris) == 2
      assert "s3://models/run/checkpoint_1000" in run.checkpoint_uris
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      run = %Run{
        id: :run_001,
        config: sample_config(),
        status: :running,
        current_epoch: 5
      }

      json = Jason.encode!(run)

      assert is_binary(json)
      assert json =~ "run_001"
      assert json =~ "running"
    end

    test "encodes nested config" do
      run = %Run{
        id: :run,
        config: sample_config()
      }

      json = Jason.encode!(run)

      assert json =~ "train_config"
      assert json =~ "gpt2"
      assert json =~ "wikitext"
    end

    test "encodes metrics history" do
      run = %Run{
        id: :run,
        config: sample_config(),
        metrics_history: [%{epoch: 1, loss: 2.5}]
      }

      json = Jason.encode!(run)

      assert json =~ "metrics_history"
      assert json =~ "2.5"
    end
  end
end
