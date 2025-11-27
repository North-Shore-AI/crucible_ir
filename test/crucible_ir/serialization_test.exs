defmodule CrucibleIR.SerializationTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.{Experiment, BackendRef, StageDef, DatasetRef}
  alias CrucibleIR.Reliability.{Config, Ensemble, Hedging, Stats}
  alias CrucibleIR.Serialization

  describe "to_json/1" do
    test "encodes BackendRef to JSON" do
      backend = %BackendRef{id: :gpt4}
      json = Serialization.to_json(backend)

      assert is_binary(json)
      assert json =~ "gpt4"
      assert json =~ "default"
    end

    test "encodes StageDef to JSON" do
      stage = %StageDef{name: :inference, enabled: true}
      json = Serialization.to_json(stage)

      assert is_binary(json)
      assert json =~ "inference"
      assert json =~ "true"
    end

    test "encodes DatasetRef to JSON" do
      dataset = %DatasetRef{name: :mmlu}
      json = Serialization.to_json(dataset)

      assert is_binary(json)
      assert json =~ "mmlu"
    end

    test "encodes Experiment to JSON" do
      exp = %Experiment{
        id: :test_exp,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}],
        description: "Test experiment"
      }

      json = Serialization.to_json(exp)

      assert is_binary(json)
      assert json =~ "test_exp"
      assert json =~ "gpt4"
      assert json =~ "run"
      assert json =~ "Test experiment"
    end

    test "encodes nested Experiment with reliability config" do
      exp = %Experiment{
        id: :complex_exp,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}],
        reliability: %Config{
          ensemble: %Ensemble{strategy: :majority, execution_mode: :parallel},
          hedging: %Hedging{strategy: :fixed, delay_ms: 100},
          stats: %Stats{alpha: 0.01, tests: [:ttest]}
        }
      }

      json = Serialization.to_json(exp)

      assert is_binary(json)
      assert json =~ "complex_exp"
      assert json =~ "majority"
      assert json =~ "parallel"
      assert json =~ "fixed"
      assert json =~ "0.01"
      assert json =~ "ttest"
    end

    test "encodes Ensemble config to JSON" do
      ensemble = %Ensemble{strategy: :weighted, models: [:gpt4, :claude]}
      json = Serialization.to_json(ensemble)

      assert is_binary(json)
      assert json =~ "weighted"
      assert json =~ "gpt4"
      assert json =~ "claude"
    end
  end

  describe "from_json/2 for BackendRef" do
    test "decodes JSON to BackendRef" do
      json = ~s({"id":"gpt4","profile":"default"})
      {:ok, backend} = Serialization.from_json(json, BackendRef)

      assert %BackendRef{} = backend
      assert backend.id == :gpt4
      assert backend.profile == :default
    end

    test "decodes JSON with options" do
      json = ~s({"id":"gpt4","profile":"fast","options":{"temperature":0.7}})
      {:ok, backend} = Serialization.from_json(json, BackendRef)

      assert backend.options == %{"temperature" => 0.7}
    end
  end

  describe "from_json/2 for StageDef" do
    test "decodes JSON to StageDef" do
      json = ~s({"name":"inference","enabled":true})
      {:ok, stage} = Serialization.from_json(json, StageDef)

      assert %StageDef{} = stage
      assert stage.name == :inference
      assert stage.enabled == true
    end

    test "decodes JSON with options" do
      json = ~s({"name":"preprocessing","enabled":false,"options":{"normalize":true}})
      {:ok, stage} = Serialization.from_json(json, StageDef)

      assert stage.name == :preprocessing
      assert stage.enabled == false
      assert stage.options == %{"normalize" => true}
    end
  end

  describe "from_json/2 for DatasetRef" do
    test "decodes JSON to DatasetRef with atom name" do
      json = ~s({"name":"mmlu","provider":"crucible_datasets"})
      {:ok, dataset} = Serialization.from_json(json, DatasetRef)

      assert %DatasetRef{} = dataset
      assert dataset.name == :mmlu
      assert dataset.provider == :crucible_datasets
    end

    test "decodes JSON to DatasetRef with string name" do
      json = ~s({"name":"Custom Dataset 2024","provider":"custom"})
      {:ok, dataset} = Serialization.from_json(json, DatasetRef)

      assert dataset.name == "Custom Dataset 2024"
    end
  end

  describe "from_json/2 for Experiment" do
    test "decodes simple experiment from JSON" do
      json = ~s({
        "id":"test_exp",
        "backend":{"id":"gpt4","profile":"default"},
        "pipeline":[{"name":"run","enabled":true}],
        "description":"Test"
      })

      {:ok, exp} = Serialization.from_json(json, Experiment)

      assert %Experiment{} = exp
      assert exp.id == :test_exp
      assert exp.backend.id == :gpt4
      assert length(exp.pipeline) == 1
      assert hd(exp.pipeline).name == :run
      assert exp.description == "Test"
    end

    test "decodes experiment with nested reliability config" do
      json = ~s({
        "id":"complex_exp",
        "backend":{"id":"gpt4"},
        "pipeline":[{"name":"run"}],
        "reliability":{
          "ensemble":{"strategy":"majority","execution_mode":"parallel"},
          "hedging":{"strategy":"fixed","delay_ms":100},
          "stats":{"alpha":0.01,"tests":["ttest"]}
        }
      })

      {:ok, exp} = Serialization.from_json(json, Experiment)

      assert exp.reliability.ensemble.strategy == :majority
      assert exp.reliability.ensemble.execution_mode == :parallel
      assert exp.reliability.hedging.strategy == :fixed
      assert exp.reliability.hedging.delay_ms == 100
      assert exp.reliability.stats.alpha == 0.01
      assert exp.reliability.stats.tests == [:ttest]
    end
  end

  describe "from_json/2 for Ensemble" do
    test "decodes Ensemble from JSON" do
      json = ~s({"strategy":"weighted","execution_mode":"sequential","models":["gpt4","claude"]})
      {:ok, ensemble} = Serialization.from_json(json, Ensemble)

      assert %Ensemble{} = ensemble
      assert ensemble.strategy == :weighted
      assert ensemble.execution_mode == :sequential
      assert ensemble.models == [:gpt4, :claude]
    end
  end

  describe "from_json/2 for Hedging" do
    test "decodes Hedging from JSON" do
      json = ~s({"strategy":"percentile","delay_ms":50,"percentile":0.95})
      {:ok, hedging} = Serialization.from_json(json, Hedging)

      assert %Hedging{} = hedging
      assert hedging.strategy == :percentile
      assert hedging.delay_ms == 50
      assert hedging.percentile == 0.95
    end
  end

  describe "from_json/2 for Stats" do
    test "decodes Stats from JSON" do
      json = ~s({"alpha":0.05,"tests":["ttest","bootstrap"],"confidence_level":0.95})
      {:ok, stats} = Serialization.from_json(json, Stats)

      assert %Stats{} = stats
      assert stats.alpha == 0.05
      assert stats.tests == [:ttest, :bootstrap]
      assert stats.confidence_level == 0.95
    end
  end

  describe "from_json/2 error handling" do
    test "returns error for invalid JSON" do
      assert {:error, _} = Serialization.from_json("invalid json", BackendRef)
    end

    test "returns error for missing required fields" do
      json = ~s({"profile":"default"})
      assert {:error, _} = Serialization.from_json(json, BackendRef)
    end
  end

  describe "from_map/2" do
    test "converts map with string keys to BackendRef" do
      map = %{"id" => "gpt4", "profile" => "default"}
      {:ok, backend} = Serialization.from_map(map, BackendRef)

      assert %BackendRef{} = backend
      assert backend.id == :gpt4
      assert backend.profile == :default
    end

    test "converts map with atom keys to BackendRef" do
      map = %{id: :gpt4, profile: :fast}
      {:ok, backend} = Serialization.from_map(map, BackendRef)

      assert backend.id == :gpt4
      assert backend.profile == :fast
    end

    test "converts nested maps to Experiment" do
      map = %{
        "id" => "test",
        "backend" => %{"id" => "gpt4"},
        "pipeline" => [%{"name" => "run"}]
      }

      {:ok, exp} = Serialization.from_map(map, Experiment)

      assert %Experiment{} = exp
      assert exp.id == :test
      assert exp.backend.id == :gpt4
      assert hd(exp.pipeline).name == :run
    end

    test "handles deeply nested reliability config" do
      map = %{
        "id" => "test",
        "backend" => %{"id" => "gpt4"},
        "pipeline" => [%{"name" => "run"}],
        "reliability" => %{
          "ensemble" => %{"strategy" => "majority"},
          "stats" => %{"alpha" => 0.01}
        }
      }

      {:ok, exp} = Serialization.from_map(map, Experiment)

      assert exp.reliability.ensemble.strategy == :majority
      assert exp.reliability.stats.alpha == 0.01
    end
  end

  describe "round-trip serialization" do
    test "BackendRef round-trip preserves data" do
      original = %BackendRef{id: :gpt4, profile: :fast, options: %{temp: 0.7}}
      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, BackendRef)

      assert decoded.id == original.id
      assert decoded.profile == original.profile
    end

    test "Experiment round-trip preserves structure" do
      original = %Experiment{
        id: :test,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}],
        description: "Test",
        tags: [:ml, :test]
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Experiment)

      assert decoded.id == original.id
      assert decoded.backend.id == original.backend.id
      assert decoded.description == original.description
      assert decoded.tags == original.tags
    end

    test "Complex experiment with reliability round-trip" do
      original = %Experiment{
        id: :complex,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}],
        reliability: %Config{
          ensemble: %Ensemble{strategy: :majority, models: [:gpt4, :claude]},
          hedging: %Hedging{strategy: :fixed, delay_ms: 100},
          stats: %Stats{alpha: 0.01}
        }
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Experiment)

      assert decoded.id == original.id
      assert decoded.reliability.ensemble.strategy == :majority
      assert decoded.reliability.ensemble.models == [:gpt4, :claude]
      assert decoded.reliability.hedging.strategy == :fixed
      assert decoded.reliability.stats.alpha == 0.01
    end
  end
end
