defmodule CrucibleIR.ReliabilityTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.Reliability.{Config, Ensemble, Hedging, Stats, Fairness, Guardrail}

  describe "Ensemble" do
    test "creates with defaults" do
      ensemble = %Ensemble{}
      assert ensemble.strategy == :none
      assert ensemble.execution_mode == :parallel
    end

    test "allows custom strategy" do
      ensemble = %Ensemble{strategy: :majority}
      assert ensemble.strategy == :majority
    end

    test "allows custom execution_mode" do
      ensemble = %Ensemble{execution_mode: :sequential}
      assert ensemble.execution_mode == :sequential
    end

    test "accepts all fields" do
      ensemble = %Ensemble{
        strategy: :weighted,
        execution_mode: :hedged,
        models: [:gpt4, :claude],
        weights: %{gpt4: 0.6, claude: 0.4},
        min_agreement: 0.8,
        timeout_ms: 5000,
        options: %{retry: true}
      }

      assert ensemble.models == [:gpt4, :claude]
      assert ensemble.weights == %{gpt4: 0.6, claude: 0.4}
      assert ensemble.min_agreement == 0.8
      assert ensemble.timeout_ms == 5000
    end

    test "encodes to JSON" do
      ensemble = %Ensemble{strategy: :majority, models: [:gpt4, :claude]}
      {:ok, json} = Jason.encode(ensemble)
      assert json =~ "majority"
    end
  end

  describe "Hedging" do
    test "creates with defaults" do
      hedging = %Hedging{}
      assert hedging.strategy == :off
    end

    test "allows custom strategy" do
      hedging = %Hedging{strategy: :fixed}
      assert hedging.strategy == :fixed
    end

    test "accepts all fields" do
      hedging = %Hedging{
        strategy: :percentile,
        delay_ms: 100,
        percentile: 0.95,
        max_hedges: 2,
        budget_percent: 15,
        options: %{adaptive: true}
      }

      assert hedging.delay_ms == 100
      assert hedging.percentile == 0.95
      assert hedging.max_hedges == 2
      assert hedging.budget_percent == 15
    end

    test "encodes to JSON" do
      hedging = %Hedging{strategy: :adaptive, delay_ms: 200}
      {:ok, json} = Jason.encode(hedging)
      assert json =~ "adaptive"
    end
  end

  describe "Stats" do
    test "creates with defaults" do
      stats = %Stats{}
      assert stats.tests == [:ttest, :bootstrap]
      assert stats.alpha == 0.05
    end

    test "allows custom tests" do
      stats = %Stats{tests: [:anova, :mannwhitney]}
      assert stats.tests == [:anova, :mannwhitney]
    end

    test "accepts all fields" do
      stats = %Stats{
        tests: [:ttest, :wilcoxon],
        alpha: 0.01,
        confidence_level: 0.99,
        effect_size_type: :cohens_d,
        multiple_testing_correction: :bonferroni,
        bootstrap_iterations: 10000,
        options: %{seed: 42}
      }

      assert stats.alpha == 0.01
      assert stats.confidence_level == 0.99
      assert stats.effect_size_type == :cohens_d
    end

    test "encodes to JSON" do
      stats = %Stats{tests: [:ttest], alpha: 0.01}
      {:ok, json} = Jason.encode(stats)
      {:ok, decoded} = Jason.decode(json)
      assert decoded["alpha"] == 0.01
    end
  end

  describe "Fairness" do
    test "creates with defaults" do
      fairness = %Fairness{}
      assert fairness.enabled == false
    end

    test "allows enabling" do
      fairness = %Fairness{enabled: true}
      assert fairness.enabled == true
    end

    test "accepts all fields" do
      fairness = %Fairness{
        enabled: true,
        metrics: [:demographic_parity, :equalized_odds],
        group_by: :gender,
        threshold: 0.8,
        fail_on_violation: true,
        options: %{report_details: true}
      }

      assert fairness.metrics == [:demographic_parity, :equalized_odds]
      assert fairness.group_by == :gender
      assert fairness.threshold == 0.8
      assert fairness.fail_on_violation == true
    end

    test "encodes to JSON" do
      fairness = %Fairness{enabled: true, metrics: [:demographic_parity]}
      {:ok, json} = Jason.encode(fairness)
      {:ok, decoded} = Jason.decode(json)
      assert decoded["enabled"] == true
    end
  end

  describe "Guardrail" do
    test "creates with defaults" do
      guardrail = %Guardrail{}
      assert guardrail.profiles == [:default]
    end

    test "allows custom profiles" do
      guardrail = %Guardrail{profiles: [:strict, :moderate]}
      assert guardrail.profiles == [:strict, :moderate]
    end

    test "accepts all fields" do
      guardrail = %Guardrail{
        profiles: [:strict],
        prompt_injection_detection: true,
        jailbreak_detection: true,
        pii_detection: true,
        pii_redaction: true,
        content_moderation: true,
        fail_on_detection: true,
        options: %{log_violations: true}
      }

      assert guardrail.prompt_injection_detection == true
      assert guardrail.jailbreak_detection == true
      assert guardrail.pii_detection == true
    end

    test "encodes to JSON" do
      guardrail = %Guardrail{profiles: [:strict], prompt_injection_detection: true}
      {:ok, json} = Jason.encode(guardrail)
      assert json =~ "strict"
    end
  end

  describe "Config" do
    test "creates with defaults" do
      config = %Config{}
      assert config.ensemble == nil
      assert config.hedging == nil
      assert config.guardrails == nil
      assert config.stats == nil
      assert config.fairness == nil
    end

    test "accepts ensemble config" do
      ensemble = %Ensemble{strategy: :majority}
      config = %Config{ensemble: ensemble}
      assert config.ensemble.strategy == :majority
    end

    test "accepts all reliability configs" do
      config = %Config{
        ensemble: %Ensemble{strategy: :weighted},
        hedging: %Hedging{strategy: :fixed},
        guardrails: %Guardrail{profiles: [:strict]},
        stats: %Stats{tests: [:ttest]},
        fairness: %Fairness{enabled: true}
      }

      assert config.ensemble.strategy == :weighted
      assert config.hedging.strategy == :fixed
      assert config.guardrails.profiles == [:strict]
      assert config.stats.tests == [:ttest]
      assert config.fairness.enabled == true
    end

    test "encodes to JSON with nested configs" do
      config = %Config{
        ensemble: %Ensemble{strategy: :majority, models: [:gpt4]},
        stats: %Stats{alpha: 0.01}
      }

      {:ok, json} = Jason.encode(config)
      {:ok, decoded} = Jason.decode(json)
      assert decoded["ensemble"]["strategy"] == "majority"
      assert decoded["stats"]["alpha"] == 0.01
    end
  end
end
