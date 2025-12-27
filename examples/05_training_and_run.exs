alias CrucibleIR.{DatasetRef, ModelRef, Serialization}
alias CrucibleIR.Training.{Config, Run}

model = %ModelRef{
  id: :hf_gpt2,
  provider: :huggingface,
  artifact_uri: "hf://gpt2",
  options: %{"token_env" => "HUGGINGFACE_TOKEN"}
}

dataset = %DatasetRef{
  name: :wikitext,
  provider: :huggingface,
  split: :train,
  options: %{"revision" => "main"}
}

config = %Config{
  id: :train_gpt2,
  model_ref: model,
  dataset_ref: dataset,
  epochs: 3,
  batch_size: 16,
  learning_rate: 0.0005,
  optimizer: :adamw,
  device: :cuda,
  options: %{"experiment_tag" => "baseline"}
}

run = %Run{
  id: :run_001,
  config: config,
  status: :running,
  current_epoch: 2,
  metrics_history: [%{"loss" => 0.8}, %{"loss" => 0.6}],
  started_at: ~U[2025-12-26 12:00:00Z]
}

IO.puts(Serialization.to_json(config))
IO.puts(Serialization.to_json(run))
