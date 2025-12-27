alias CrucibleIR.{BackendRef, Experiment, Serialization, StageDef}

original = %Experiment{
  id: :round_trip_demo,
  backend: %BackendRef{id: :openai_gpt4},
  pipeline: [%StageDef{name: :inference}],
  description: "Round-trip example"
}

json = Serialization.to_json(original)
{:ok, decoded} = Serialization.from_json(json, Experiment)

IO.puts(json)
IO.inspect(decoded, label: "decoded")
