alias CrucibleIR.{BackendRef, Experiment, Serialization, StageDef}

openai_exp = %Experiment{
  id: :openai_eval,
  backend: %BackendRef{
    id: :openai_gpt4,
    model_version: "gpt-4.1",
    profile: :default,
    options: %{
      "api_key_env" => "OPENAI_API_KEY",
      "temperature" => 0.2
    }
  },
  pipeline: [%StageDef{name: :inference}]
}

anthropic_exp = %Experiment{
  id: :anthropic_eval,
  backend: %BackendRef{
    id: :anthropic_claude_3_5,
    endpoint_url: "https://api.anthropic.com",
    profile: :default,
    deployment_id: :prod_anthropic,
    options: %{
      "api_key_env" => "ANTHROPIC_API_KEY",
      "max_tokens" => 1024
    },
    fallback: %BackendRef{id: :openai_gpt4}
  },
  pipeline: [%StageDef{name: :inference}]
}

IO.puts(Serialization.to_json(openai_exp))
IO.puts(Serialization.to_json(anthropic_exp))
