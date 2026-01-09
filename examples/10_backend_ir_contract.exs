alias CrucibleIR.Backend.{Capabilities, Completion, Options, Prompt}
alias CrucibleIR.Serialization

prompt = %Prompt{
  messages: [%{role: :user, content: "Summarize this text."}],
  options: %Options{
    model: "gpt-4o",
    temperature: 0.2,
    response_format: :text
  }
}

completion = %Completion{
  model: "gpt-4o",
  choices: [
    %{index: 0, message: %{role: :assistant, content: "Summary..."}, finish_reason: :stop}
  ],
  usage: %{prompt_tokens: 10, completion_tokens: 5, total_tokens: 15}
}

caps = %Capabilities{
  backend_id: :openai,
  provider: "openai",
  models: ["gpt-4o"],
  supports_streaming: true,
  supports_tools: true,
  max_context_length: 128_000
}

IO.puts(Serialization.to_json(prompt))
IO.puts(Serialization.to_json(completion))
IO.puts(Serialization.to_json(caps))
