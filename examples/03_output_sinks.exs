alias CrucibleIR.{BackendRef, Experiment, OutputSpec, Serialization, StageDef}

exp = %Experiment{
  id: :outputs_demo,
  backend: %BackendRef{id: :openai_gpt4},
  pipeline: [%StageDef{name: :inference}],
  outputs: [
    %OutputSpec{
      name: :report,
      formats: [:markdown],
      sink: :file,
      options: %{"path" => "reports/report.md"}
    },
    %OutputSpec{
      name: :preview,
      formats: [:json],
      sink: :stdout
    },
    %OutputSpec{
      name: :archive,
      formats: [:json],
      sink: :s3,
      options: %{
        "bucket" => "crucible-results",
        "prefix" => "runs/",
        "region" => "us-east-1"
      }
    },
    %OutputSpec{
      name: :metrics,
      formats: [:csv],
      sink: :postgres,
      options: %{"table" => "experiment_metrics"}
    }
  ]
}

IO.puts(Serialization.to_json(exp))
