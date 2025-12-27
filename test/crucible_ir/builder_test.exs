defmodule CrucibleIR.BuilderTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.Builder
  alias CrucibleIR.Experiment

  describe "experiment/1" do
    test "creates a new experiment builder" do
      exp = Builder.experiment(:test_exp)

      assert %Experiment{} = exp
      assert exp.id == :test_exp
    end
  end

  describe "with_description/2" do
    test "adds description to experiment" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_description("Test experiment")

      assert exp.description == "Test experiment"
    end
  end

  describe "with_backend/2" do
    test "adds backend with atom id" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_backend(:gpt4)

      assert exp.backend.id == :gpt4
      assert exp.backend.profile == :default
    end

    test "adds backend with options" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_backend(:gpt4, profile: :fast, options: %{temperature: 0.7})

      assert exp.backend.id == :gpt4
      assert exp.backend.profile == :fast
      assert exp.backend.options == %{temperature: 0.7}
    end
  end

  describe "add_stage/2" do
    test "adds a stage to pipeline" do
      exp =
        Builder.experiment(:test)
        |> Builder.add_stage(:preprocessing)

      assert length(exp.pipeline) == 1
      assert hd(exp.pipeline).name == :preprocessing
    end

    test "adds stage with options" do
      exp =
        Builder.experiment(:test)
        |> Builder.add_stage(:preprocessing, enabled: false, options: %{normalize: true})

      stage = hd(exp.pipeline)
      assert stage.name == :preprocessing
      assert stage.enabled == false
      assert stage.options == %{normalize: true}
    end

    test "adds multiple stages" do
      exp =
        Builder.experiment(:test)
        |> Builder.add_stage(:preprocessing)
        |> Builder.add_stage(:inference)
        |> Builder.add_stage(:postprocessing)

      assert length(exp.pipeline) == 3
      assert Enum.map(exp.pipeline, & &1.name) == [:preprocessing, :inference, :postprocessing]
    end
  end

  describe "with_dataset/2" do
    test "adds dataset with atom name" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_dataset(:mmlu)

      assert exp.dataset.name == :mmlu
    end

    test "adds dataset with string name" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_dataset("Custom Dataset")

      assert exp.dataset.name == "Custom Dataset"
    end

    test "adds dataset with options" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_dataset(:mmlu, split: :test, provider: :custom)

      assert exp.dataset.name == :mmlu
      assert exp.dataset.split == :test
      assert exp.dataset.provider == :custom
    end
  end

  describe "with_ensemble/2" do
    test "adds ensemble with strategy" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_ensemble(:majority)

      assert exp.reliability.ensemble.strategy == :majority
    end

    test "adds ensemble with options" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_ensemble(:weighted,
          execution_mode: :sequential,
          models: [:gpt4, :claude],
          timeout_ms: 5000
        )

      ensemble = exp.reliability.ensemble
      assert ensemble.strategy == :weighted
      assert ensemble.execution_mode == :sequential
      assert ensemble.models == [:gpt4, :claude]
      assert ensemble.timeout_ms == 5000
    end

    test "preserves existing reliability config" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_stats([:ttest])
        |> Builder.with_ensemble(:majority)

      assert exp.reliability.ensemble.strategy == :majority
      assert exp.reliability.stats.tests == [:ttest]
    end
  end

  describe "with_hedging/2" do
    test "adds hedging with strategy" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_hedging(:fixed)

      assert exp.reliability.hedging.strategy == :fixed
    end

    test "adds hedging with options" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_hedging(:percentile, delay_ms: 100, percentile: 0.95)

      hedging = exp.reliability.hedging
      assert hedging.strategy == :percentile
      assert hedging.delay_ms == 100
      assert hedging.percentile == 0.95
    end
  end

  describe "with_stats/2" do
    test "adds stats with test list" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_stats([:ttest, :bootstrap])

      assert exp.reliability.stats.tests == [:ttest, :bootstrap]
    end

    test "adds stats with options" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_stats([:ttest], alpha: 0.01, confidence_level: 0.99)

      stats = exp.reliability.stats
      assert stats.tests == [:ttest]
      assert stats.alpha == 0.01
      assert stats.confidence_level == 0.99
    end
  end

  describe "with_fairness/1" do
    test "adds fairness config" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_fairness(metrics: [:demographic_parity], threshold: 0.8)

      fairness = exp.reliability.fairness
      assert fairness.metrics == [:demographic_parity]
      assert fairness.threshold == 0.8
    end

    test "enables fairness by default" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_fairness(metrics: [:demographic_parity])

      assert exp.reliability.fairness.enabled == true
    end
  end

  describe "with_guardrails/1" do
    test "adds guardrails config" do
      exp =
        Builder.experiment(:test)
        |> Builder.with_guardrails(
          profiles: [:strict],
          prompt_injection_detection: true,
          pii_detection: true
        )

      guardrail = exp.reliability.guardrails
      assert guardrail.profiles == [:strict]
      assert guardrail.prompt_injection_detection == true
      assert guardrail.pii_detection == true
    end
  end

  describe "add_output/2" do
    test "adds output spec" do
      exp =
        Builder.experiment(:test)
        |> Builder.add_output(:results)

      assert length(exp.outputs) == 1
      assert hd(exp.outputs).name == :results
    end

    test "adds output with options" do
      exp =
        Builder.experiment(:test)
        |> Builder.add_output(:results, formats: [:json, :html], sink: :s3)

      output = hd(exp.outputs)
      assert output.name == :results
      assert output.formats == [:json, :html]
      assert output.sink == :s3
    end

    test "adds multiple outputs" do
      exp =
        Builder.experiment(:test)
        |> Builder.add_output(:results)
        |> Builder.add_output(:metrics)
        |> Builder.add_output(:traces)

      assert length(exp.outputs) == 3
      assert Enum.map(exp.outputs, & &1.name) == [:results, :metrics, :traces]
    end
  end

  describe "build/1" do
    test "validates and returns {:ok, experiment} for valid experiment" do
      {:ok, exp} =
        Builder.experiment(:test)
        |> Builder.with_backend(:gpt4)
        |> Builder.add_stage(:run)
        |> Builder.build()

      assert %Experiment{} = exp
      assert exp.id == :test
      assert exp.backend.id == :gpt4
      assert length(exp.pipeline) == 1
    end

    test "returns {:error, errors} for invalid experiment" do
      {:error, errors} =
        Builder.experiment(:test)
        |> Builder.build()

      assert is_list(errors)
      assert "backend is required" in errors
      assert "pipeline must contain at least one stage" in errors
    end

    test "returns {:error, errors} for experiment with empty pipeline" do
      {:error, errors} =
        Builder.experiment(:test)
        |> Builder.with_backend(:gpt4)
        |> Builder.build()

      assert "pipeline must contain at least one stage" in errors
    end

    test "validates nested reliability configs" do
      {:error, errors} =
        Builder.experiment(:test)
        |> Builder.with_backend(:gpt4)
        |> Builder.add_stage(:run)
        |> Builder.with_ensemble(:invalid_strategy)
        |> Builder.build()

      assert Enum.any?(errors, &String.contains?(&1, "ensemble.strategy"))
    end
  end

  describe "fluent chaining" do
    test "builds complete experiment with all options" do
      {:ok, exp} =
        Builder.experiment(:comprehensive_test)
        |> Builder.with_description("Comprehensive reliability experiment")
        |> Builder.with_backend(:gpt4, profile: :fast)
        |> Builder.add_stage(:preprocessing, options: %{normalize: true})
        |> Builder.add_stage(:inference)
        |> Builder.add_stage(:postprocessing)
        |> Builder.with_dataset(:mmlu, split: :test)
        |> Builder.with_ensemble(:majority, models: [:gpt4, :claude])
        |> Builder.with_hedging(:fixed, delay_ms: 100)
        |> Builder.with_stats([:ttest, :bootstrap], alpha: 0.01)
        |> Builder.with_fairness(metrics: [:demographic_parity], threshold: 0.8)
        |> Builder.with_guardrails(profiles: [:strict], pii_detection: true)
        |> Builder.add_output(:results, formats: [:json, :html])
        |> Builder.add_output(:metrics, formats: [:csv])
        |> Builder.build()

      assert exp.id == :comprehensive_test
      assert exp.description == "Comprehensive reliability experiment"
      assert exp.backend.id == :gpt4
      assert exp.backend.profile == :fast
      assert length(exp.pipeline) == 3
      assert exp.dataset.name == :mmlu
      assert exp.reliability.ensemble.strategy == :majority
      assert exp.reliability.hedging.strategy == :fixed
      assert exp.reliability.stats.alpha == 0.01
      assert exp.reliability.fairness.threshold == 0.8
      assert exp.reliability.guardrails.pii_detection == true
      assert length(exp.outputs) == 2
    end

    test "builds minimal valid experiment" do
      {:ok, exp} =
        Builder.experiment(:minimal)
        |> Builder.with_backend(:gpt4)
        |> Builder.add_stage(:run)
        |> Builder.build()

      assert exp.id == :minimal
      assert exp.backend.id == :gpt4
      assert length(exp.pipeline) == 1
    end
  end
end
