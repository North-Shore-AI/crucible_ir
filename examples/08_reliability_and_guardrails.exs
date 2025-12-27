alias CrucibleIR.{BackendRef, Experiment, Serialization, StageDef}
alias CrucibleIR.Reliability.{Config, Ensemble, Fairness, Guardrail, Hedging, Stats}

exp = %Experiment{
  id: :reliability_demo,
  backend: %BackendRef{id: :openai_gpt4},
  pipeline: [%StageDef{name: :inference}],
  reliability: %Config{
    ensemble: %Ensemble{
      strategy: :weighted,
      execution_mode: :parallel,
      models: [:gpt4, :claude],
      weights: %{gpt4: 0.6, claude: 0.4}
    },
    hedging: %Hedging{strategy: :fixed, delay_ms: 100},
    stats: %Stats{alpha: 0.01, tests: [:ttest, :bootstrap]},
    fairness: %Fairness{
      enabled: true,
      metrics: [:demographic_parity],
      group_by: :gender,
      threshold: 0.8,
      fail_on_violation: true
    },
    guardrails: %Guardrail{
      profiles: [:strict],
      prompt_injection_detection: true,
      pii_detection: true,
      fail_on_detection: true
    }
  }
}

IO.puts(Serialization.to_json(exp))
