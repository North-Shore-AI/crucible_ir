alias CrucibleIR.Feedback
alias CrucibleIR.Serialization

configs = [
  %Feedback.Config{
    enabled: true,
    sampling_rate: 0.1,
    storage: :postgres,
    options: %{"database_url_env" => "DATABASE_URL"}
  },
  %Feedback.Config{
    enabled: true,
    sampling_rate: 0.2,
    storage: :s3,
    options: %{
      "bucket" => "crucible-feedback",
      "region" => "us-east-1",
      "access_key_env" => "AWS_ACCESS_KEY_ID",
      "secret_key_env" => "AWS_SECRET_ACCESS_KEY"
    }
  },
  %Feedback.Config{
    enabled: true,
    sampling_rate: 0.05,
    storage: :bigquery,
    options: %{
      "project_id" => "example-project",
      "dataset" => "feedback",
      "credentials_env" => "GOOGLE_APPLICATION_CREDENTIALS"
    }
  },
  %Feedback.Config{
    enabled: true,
    sampling_rate: 1.0,
    storage: :local,
    options: %{"path" => "./feedback"}
  }
]

event = %Feedback.Event{
  id: "evt_123",
  deployment_id: :deploy_prod,
  model_version: "1.0.0",
  input: %{"prompt" => "Hello"},
  output: %{"text" => "Hi"},
  feedback_type: :thumbs,
  feedback_value: :up,
  user_id: "user_1",
  session_id: "session_1",
  latency_ms: 120,
  timestamp: ~U[2025-12-26 12:10:00Z],
  metadata: %{"source" => "web"}
}

Enum.each(configs, fn config ->
  IO.puts(Serialization.to_json(config))
end)

IO.puts(Serialization.to_json(event))
