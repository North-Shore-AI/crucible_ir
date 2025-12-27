alias CrucibleIR.Deployment.{Config, Status}
alias CrucibleIR.Serialization

config = %Config{
  id: :deploy_prod,
  model_version_id: :gpt2_v1,
  environment: :production,
  strategy: :canary,
  replicas: 3,
  target: %{
    "provider" => "kubernetes",
    "namespace" => "ml"
  },
  endpoint: %{
    "url" => "https://api.example.com/v1",
    "auth" => %{"token_env" => "DEPLOYMENT_API_TOKEN"}
  },
  resources: %{"cpu" => "2", "memory" => "4Gi"},
  scaling: %{"min" => 2, "max" => 5},
  metadata: %{"owner" => "mlops"}
}

status = %Status{
  id: :deploy_status_001,
  deployment_id: :deploy_prod,
  state: :active,
  health: :healthy,
  ready_replicas: 3,
  total_replicas: 3,
  endpoint_url: "https://api.example.com/v1",
  last_health_check: ~U[2025-12-26 12:05:00Z]
}

IO.puts(Serialization.to_json(config))
IO.puts(Serialization.to_json(status))
