alias CrucibleIR.{ModelRef, ModelVersion, Serialization}

models = [
  %ModelRef{
    id: :local_gpt2,
    name: "GPT-2 Local",
    provider: :local,
    artifact_uri: "file:///models/gpt2"
  },
  %ModelRef{
    id: :hf_gpt2,
    name: "GPT-2 HF",
    provider: :huggingface,
    artifact_uri: "hf://gpt2",
    options: %{"token_env" => "HUGGINGFACE_TOKEN"}
  },
  %ModelRef{
    id: :openai_gpt4,
    name: "GPT-4",
    provider: :openai,
    options: %{"api_key_env" => "OPENAI_API_KEY"}
  },
  %ModelRef{
    id: :anthropic_claude,
    name: "Claude",
    provider: :anthropic,
    options: %{"api_key_env" => "ANTHROPIC_API_KEY"}
  },
  %ModelRef{
    id: :s3_model,
    name: "S3 Model",
    provider: :s3,
    artifact_uri: "s3://models/gpt2/v1.tar.gz",
    options: %{"region" => "us-east-1"}
  },
  %ModelRef{
    id: :gcs_model,
    name: "GCS Model",
    provider: :gcs,
    artifact_uri: "gs://models/gpt2/v1.tar.gz",
    options: %{"project" => "example-project"}
  }
]

version = %ModelVersion{
  id: :gpt2_v1,
  model_id: :local_gpt2,
  version: "1.0.0",
  stage: :production,
  artifact_uri: "s3://models/gpt2/v1.tar.gz",
  created_at: ~U[2025-12-26 12:00:00Z],
  created_by: "mlops"
}

Enum.each(models, fn model ->
  IO.puts(Serialization.to_json(model))
end)

IO.puts(Serialization.to_json(version))
