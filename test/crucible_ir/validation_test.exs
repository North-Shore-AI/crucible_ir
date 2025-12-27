defmodule CrucibleIR.ValidationTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.{BackendRef, DatasetRef, Experiment, OutputSpec, StageDef}
  alias CrucibleIR.Reliability.{Config, Ensemble, Fairness, Guardrail, Hedging, Stats}
  alias CrucibleIR.Validation

  describe "validate/1 for Experiment" do
    test "returns {:ok, experiment} for valid experiment" do
      exp = %Experiment{
        id: :test_exp,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}]
      }

      assert {:ok, ^exp} = Validation.validate(exp)
    end

    test "returns error for empty id" do
      exp = %Experiment{
        id: :"",
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}]
      }

      assert {:error, errors} = Validation.validate(exp)
      assert "id must be non-empty atom" in errors
    end

    test "returns error for nil backend" do
      exp = %Experiment{
        id: :test,
        backend: nil,
        pipeline: [%StageDef{name: :run}]
      }

      assert {:error, errors} = Validation.validate(exp)
      assert "backend is required" in errors
    end

    test "returns error for invalid backend" do
      exp = %Experiment{
        id: :test,
        backend: %BackendRef{id: nil},
        pipeline: [%StageDef{name: :run}]
      }

      assert {:error, errors} = Validation.validate(exp)
      assert "backend.id must be a non-nil atom" in errors
    end

    test "returns error for nil pipeline" do
      exp = %Experiment{
        id: :test,
        backend: %BackendRef{id: :gpt4},
        pipeline: nil
      }

      assert {:error, errors} = Validation.validate(exp)
      assert "pipeline must be a list" in errors
    end

    test "returns error for empty pipeline" do
      exp = %Experiment{
        id: :test,
        backend: %BackendRef{id: :gpt4},
        pipeline: []
      }

      assert {:error, errors} = Validation.validate(exp)
      assert "pipeline must contain at least one stage" in errors
    end

    test "returns error for invalid stage in pipeline" do
      exp = %Experiment{
        id: :test,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: nil}]
      }

      assert {:error, errors} = Validation.validate(exp)
      assert "pipeline stage name must be a non-nil atom" in errors
    end

    test "returns multiple errors for multiple issues" do
      exp = %Experiment{
        id: :"",
        backend: nil,
        pipeline: nil
      }

      assert {:error, errors} = Validation.validate(exp)
      assert length(errors) >= 3
    end

    test "validates nested reliability config" do
      exp = %Experiment{
        id: :test,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}],
        reliability: %Config{
          ensemble: %Ensemble{strategy: :invalid_strategy}
        }
      }

      assert {:error, errors} = Validation.validate(exp)

      assert "ensemble.strategy must be one of: none, majority, weighted, best_confidence, unanimous" in errors
    end
  end

  describe "validate/1 for BackendRef" do
    test "returns {:ok, backend} for valid backend" do
      backend = %BackendRef{id: :gpt4}
      assert {:ok, ^backend} = Validation.validate(backend)
    end

    test "returns error for nil id" do
      backend = %BackendRef{id: nil}
      assert {:error, errors} = Validation.validate(backend)
      assert "id must be a non-nil atom" in errors
    end

    test "accepts valid profile" do
      backend = %BackendRef{id: :gpt4, profile: :fast}
      assert {:ok, ^backend} = Validation.validate(backend)
    end
  end

  describe "validate/1 for StageDef" do
    test "returns {:ok, stage} for valid stage" do
      stage = %StageDef{name: :inference}
      assert {:ok, ^stage} = Validation.validate(stage)
    end

    test "returns error for nil name" do
      stage = %StageDef{name: nil}
      assert {:error, errors} = Validation.validate(stage)
      assert "name must be a non-nil atom" in errors
    end
  end

  describe "validate/1 for DatasetRef" do
    test "returns {:ok, dataset} for valid dataset with atom name" do
      dataset = %DatasetRef{name: :mmlu}
      assert {:ok, ^dataset} = Validation.validate(dataset)
    end

    test "returns {:ok, dataset} for valid dataset with string name" do
      dataset = %DatasetRef{name: "custom_dataset"}
      assert {:ok, ^dataset} = Validation.validate(dataset)
    end

    test "returns {:ok, dataset} for nil name" do
      dataset = %DatasetRef{name: nil}
      assert {:ok, ^dataset} = Validation.validate(dataset)
    end

    test "returns error for empty string name" do
      dataset = %DatasetRef{name: ""}
      assert {:error, errors} = Validation.validate(dataset)
      assert "name must be non-empty when set" in errors
    end
  end

  describe "validate/1 for OutputSpec" do
    test "returns {:ok, output} for valid output" do
      output = %OutputSpec{name: :results}
      assert {:ok, ^output} = Validation.validate(output)
    end

    test "returns error for nil name" do
      output = %OutputSpec{name: nil}
      assert {:error, errors} = Validation.validate(output)
      assert "name must be a non-nil atom" in errors
    end
  end

  describe "validate/1 for Ensemble" do
    test "returns {:ok, ensemble} for valid strategies" do
      strategies = [:none, :majority, :weighted, :best_confidence, :unanimous]

      for strategy <- strategies do
        ensemble = %Ensemble{strategy: strategy}
        assert {:ok, ^ensemble} = Validation.validate(ensemble)
      end
    end

    test "returns error for invalid strategy" do
      ensemble = %Ensemble{strategy: :invalid}
      assert {:error, errors} = Validation.validate(ensemble)

      assert "strategy must be one of: none, majority, weighted, best_confidence, unanimous" in errors
    end

    test "validates execution modes" do
      modes = [:parallel, :sequential, :hedged, :cascade]

      for mode <- modes do
        ensemble = %Ensemble{execution_mode: mode}
        assert {:ok, ^ensemble} = Validation.validate(ensemble)
      end
    end

    test "returns error for invalid execution mode" do
      ensemble = %Ensemble{execution_mode: :invalid}
      assert {:error, errors} = Validation.validate(ensemble)
      assert "execution_mode must be one of: parallel, sequential, hedged, cascade" in errors
    end
  end

  describe "validate/1 for Hedging" do
    test "returns {:ok, hedging} for valid strategies" do
      strategies = [:off, :fixed, :percentile, :adaptive, :workload_aware]

      for strategy <- strategies do
        hedging = %Hedging{strategy: strategy}
        assert {:ok, ^hedging} = Validation.validate(hedging)
      end
    end

    test "returns error for invalid strategy" do
      hedging = %Hedging{strategy: :invalid}
      assert {:error, errors} = Validation.validate(hedging)
      assert "strategy must be one of: off, fixed, percentile, adaptive, workload_aware" in errors
    end
  end

  describe "validate/1 for Stats" do
    test "returns {:ok, stats} for valid stats" do
      stats = %Stats{alpha: 0.05}
      assert {:ok, ^stats} = Validation.validate(stats)
    end

    test "returns error for alpha out of range" do
      stats = %Stats{alpha: 1.5}
      assert {:error, errors} = Validation.validate(stats)
      assert "alpha must be between 0 and 1" in errors
    end

    test "returns error for negative alpha" do
      stats = %Stats{alpha: -0.1}
      assert {:error, errors} = Validation.validate(stats)
      assert "alpha must be between 0 and 1" in errors
    end
  end

  describe "validate/1 for Fairness" do
    test "returns {:ok, fairness} for valid fairness config" do
      fairness = %Fairness{}
      assert {:ok, ^fairness} = Validation.validate(fairness)
    end
  end

  describe "validate/1 for Guardrail" do
    test "returns {:ok, guardrail} for valid guardrail config" do
      guardrail = %Guardrail{}
      assert {:ok, ^guardrail} = Validation.validate(guardrail)
    end
  end

  describe "validate/1 for Reliability.Config" do
    test "returns {:ok, config} for valid config" do
      config = %Config{
        ensemble: %Ensemble{strategy: :majority},
        hedging: %Hedging{strategy: :fixed}
      }

      assert {:ok, ^config} = Validation.validate(config)
    end

    test "returns error for invalid nested configs" do
      config = %Config{
        ensemble: %Ensemble{strategy: :invalid}
      }

      assert {:error, errors} = Validation.validate(config)

      assert "ensemble.strategy must be one of: none, majority, weighted, best_confidence, unanimous" in errors
    end
  end

  describe "valid?/1" do
    test "returns true for valid experiment" do
      exp = %Experiment{
        id: :test,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}]
      }

      assert Validation.valid?(exp) == true
    end

    test "returns false for invalid experiment" do
      exp = %Experiment{
        id: :"",
        backend: nil,
        pipeline: nil
      }

      assert Validation.valid?(exp) == false
    end

    test "returns true for valid backend" do
      backend = %BackendRef{id: :gpt4}
      assert Validation.valid?(backend) == true
    end

    test "returns false for invalid backend" do
      backend = %BackendRef{id: nil}
      assert Validation.valid?(backend) == false
    end
  end

  describe "errors/1" do
    test "returns empty list for valid experiment" do
      exp = %Experiment{
        id: :test,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}]
      }

      assert Validation.errors(exp) == []
    end

    test "returns list of errors for invalid experiment" do
      exp = %Experiment{
        id: :"",
        backend: nil,
        pipeline: nil
      }

      errors = Validation.errors(exp)
      assert is_list(errors)
      assert match?([_, _, _ | _], errors)
    end

    test "returns empty list for valid backend" do
      backend = %BackendRef{id: :gpt4}
      assert Validation.errors(backend) == []
    end

    test "returns list of errors for invalid backend" do
      backend = %BackendRef{id: nil}
      errors = Validation.errors(backend)
      assert is_list(errors)
      refute Enum.empty?(errors)
    end
  end
end
