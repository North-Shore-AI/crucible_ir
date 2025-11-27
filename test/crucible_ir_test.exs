defmodule CrucibleIRTest do
  use ExUnit.Case, async: true
  doctest CrucibleIR

  alias CrucibleIR
  alias CrucibleIR.{Experiment, BackendRef, StageDef, DatasetRef}
  alias CrucibleIR.Reliability.{Config, Ensemble}

  describe "new_experiment/1" do
    test "creates experiment with required fields" do
      exp =
        CrucibleIR.new_experiment(
          id: :test_exp,
          backend: %BackendRef{id: :gpt4},
          pipeline: [%StageDef{name: :run}]
        )

      assert %Experiment{} = exp
      assert exp.id == :test_exp
      assert exp.backend.id == :gpt4
    end

    test "creates experiment with all fields" do
      exp =
        CrucibleIR.new_experiment(
          id: :full_exp,
          backend: %BackendRef{id: :gpt4},
          pipeline: [%StageDef{name: :run}],
          description: "Test",
          dataset: %DatasetRef{name: :mmlu},
          reliability: %Config{ensemble: %Ensemble{strategy: :majority}}
        )

      assert exp.description == "Test"
      assert exp.dataset.name == :mmlu
      assert exp.reliability.ensemble.strategy == :majority
    end
  end

  describe "module exports" do
    test "exports all main structs" do
      # Just verify we can access the aliases
      assert %Experiment{} = %CrucibleIR.Experiment{
               id: :test,
               backend: %BackendRef{id: :gpt4},
               pipeline: []
             }

      assert %BackendRef{} = %CrucibleIR.BackendRef{id: :gpt4}
      assert %DatasetRef{} = %CrucibleIR.DatasetRef{name: :mmlu}
      assert %StageDef{} = %CrucibleIR.StageDef{name: :run}
    end

    test "exports reliability configs" do
      assert %Config{} = %CrucibleIR.Reliability.Config{}
      assert %Ensemble{} = %CrucibleIR.Reliability.Ensemble{}
    end
  end
end
