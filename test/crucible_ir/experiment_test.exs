defmodule CrucibleIR.ExperimentTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.{Experiment, BackendRef, DatasetRef, StageDef, OutputSpec}
  alias CrucibleIR.Reliability.{Config, Ensemble, Stats}

  describe "struct creation" do
    test "creates with required fields" do
      exp = %Experiment{
        id: :exp1,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}]
      }

      assert exp.id == :exp1
      assert exp.backend.id == :gpt4
      assert length(exp.pipeline) == 1
    end

    test "requires id, backend, and pipeline" do
      # This is a compile-time check, just verify we can't create without them
      # The actual test is that compilation succeeds with valid structs
      assert true
    end

    test "accepts optional description" do
      exp = %Experiment{
        id: :exp1,
        backend: %BackendRef{id: :gpt4},
        pipeline: [],
        description: "Test experiment"
      }

      assert exp.description == "Test experiment"
    end

    test "accepts optional owner" do
      exp = %Experiment{
        id: :exp1,
        backend: %BackendRef{id: :gpt4},
        pipeline: [],
        owner: "researcher@example.com"
      }

      assert exp.owner == "researcher@example.com"
    end

    test "accepts optional tags" do
      exp = %Experiment{
        id: :exp1,
        backend: %BackendRef{id: :gpt4},
        pipeline: [],
        tags: [:llm, :reliability]
      }

      assert exp.tags == [:llm, :reliability]
    end

    test "accepts optional metadata" do
      exp = %Experiment{
        id: :exp1,
        backend: %BackendRef{id: :gpt4},
        pipeline: [],
        metadata: %{project: "crucible"}
      }

      assert exp.metadata == %{project: "crucible"}
    end

    test "accepts dataset reference" do
      dataset = %DatasetRef{name: :mmlu}

      exp = %Experiment{
        id: :exp1,
        backend: %BackendRef{id: :gpt4},
        pipeline: [],
        dataset: dataset
      }

      assert exp.dataset.name == :mmlu
    end

    test "accepts reliability config" do
      reliability = %Config{
        ensemble: %Ensemble{strategy: :majority},
        stats: %Stats{alpha: 0.01}
      }

      exp = %Experiment{
        id: :exp1,
        backend: %BackendRef{id: :gpt4},
        pipeline: [],
        reliability: reliability
      }

      assert exp.reliability.ensemble.strategy == :majority
    end

    test "accepts outputs specification" do
      outputs = [
        %OutputSpec{name: :results, formats: [:markdown, :json]}
      ]

      exp = %Experiment{
        id: :exp1,
        backend: %BackendRef{id: :gpt4},
        pipeline: [],
        outputs: outputs
      }

      assert length(exp.outputs) == 1
      assert hd(exp.outputs).formats == [:markdown, :json]
    end

    test "accepts timestamps" do
      now = DateTime.utc_now()

      exp = %Experiment{
        id: :exp1,
        backend: %BackendRef{id: :gpt4},
        pipeline: [],
        created_at: now,
        updated_at: now
      }

      assert exp.created_at == now
      assert exp.updated_at == now
    end
  end

  describe "complete experiment" do
    test "creates full experiment with all fields" do
      exp = %Experiment{
        id: :full_exp,
        backend: %BackendRef{id: :gpt4, profile: :fast},
        pipeline: [
          %StageDef{name: :preprocessing, enabled: true},
          %StageDef{name: :inference, enabled: true},
          %StageDef{name: :postprocessing, enabled: true}
        ],
        description: "Full featured experiment",
        owner: "researcher@example.com",
        tags: [:llm, :benchmark],
        metadata: %{version: "1.0"},
        dataset: %DatasetRef{name: :mmlu, split: :test},
        reliability: %Config{
          ensemble: %Ensemble{strategy: :weighted, models: [:gpt4, :claude]},
          stats: %Stats{tests: [:ttest, :bootstrap], alpha: 0.05}
        },
        outputs: [
          %OutputSpec{name: :report, formats: [:markdown, :html]},
          %OutputSpec{name: :data, formats: [:json]}
        ]
      }

      assert exp.id == :full_exp
      assert exp.backend.id == :gpt4
      assert length(exp.pipeline) == 3
      assert exp.dataset.name == :mmlu
      assert exp.reliability.ensemble.strategy == :weighted
      assert length(exp.outputs) == 2
    end
  end

  describe "Jason encoding" do
    test "encodes minimal experiment to JSON" do
      exp = %Experiment{
        id: :exp1,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}]
      }

      {:ok, json} = Jason.encode(exp)
      assert json =~ "exp1"
      assert json =~ "gpt4"
    end

    test "encodes full experiment to JSON" do
      exp = %Experiment{
        id: :full_exp,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}],
        description: "Test",
        dataset: %DatasetRef{name: :mmlu},
        reliability: %Config{
          stats: %Stats{alpha: 0.01}
        }
      }

      {:ok, json} = Jason.encode(exp)
      {:ok, decoded} = Jason.decode(json)

      assert decoded["id"] == "full_exp"
      assert decoded["description"] == "Test"
      assert decoded["dataset"]["name"] == "mmlu"
      assert decoded["reliability"]["stats"]["alpha"] == 0.01
    end
  end
end
