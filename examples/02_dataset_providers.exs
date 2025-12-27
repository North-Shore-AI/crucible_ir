alias CrucibleIR.{BackendRef, DatasetRef, Experiment, Serialization, StageDef}

crucible_exp = %Experiment{
  id: :crucible_dataset_eval,
  backend: %BackendRef{id: :openai_gpt4},
  pipeline: [%StageDef{name: :inference}],
  dataset: %DatasetRef{
    name: :mmlu,
    provider: :crucible_datasets,
    split: :test,
    options: %{
      "limit" => 100
    }
  }
}

huggingface_exp = %Experiment{
  id: :huggingface_dataset_eval,
  backend: %BackendRef{id: :openai_gpt4},
  pipeline: [%StageDef{name: :inference}],
  dataset: %DatasetRef{
    name: "wikitext-103",
    provider: :huggingface,
    split: :train,
    options: %{
      "revision" => "main",
      "token_env" => "HUGGINGFACE_TOKEN"
    }
  }
}

IO.puts(Serialization.to_json(crucible_exp))
IO.puts(Serialization.to_json(huggingface_exp))
