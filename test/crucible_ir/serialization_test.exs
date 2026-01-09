defmodule CrucibleIR.SerializationTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.{
    BackendRef,
    DatasetRef,
    Deployment,
    Experiment,
    Feedback,
    ModelRef,
    ModelVersion,
    OutputSpec,
    Serialization,
    StageDef,
    Training
  }

  alias CrucibleIR.Backend.{Capabilities, Completion, Options, Prompt}

  alias CrucibleIR.Reliability.{Config, Ensemble, Fairness, Guardrail, Hedging, Stats}

  describe "to_json/1" do
    test "encodes BackendRef to JSON" do
      backend = %BackendRef{id: :gpt4}
      json = Serialization.to_json(backend)

      assert is_binary(json)
      assert json =~ "gpt4"
      assert json =~ "default"
    end

    test "encodes StageDef to JSON" do
      stage = %StageDef{name: :inference, enabled: true}
      json = Serialization.to_json(stage)

      assert is_binary(json)
      assert json =~ "inference"
      assert json =~ "true"
    end

    test "encodes DatasetRef to JSON" do
      dataset = %DatasetRef{name: :mmlu}
      json = Serialization.to_json(dataset)

      assert is_binary(json)
      assert json =~ "mmlu"
    end

    test "encodes Backend Prompt to JSON" do
      prompt = %Prompt{
        messages: [%{role: :user, content: "Hello"}],
        options: %Options{model: "gpt-4o"}
      }

      json = Serialization.to_json(prompt)

      assert is_binary(json)
      assert json =~ "messages"
      assert json =~ "Hello"
      assert json =~ "gpt-4o"
    end

    test "encodes Experiment to JSON" do
      exp = %Experiment{
        id: :test_exp,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}],
        description: "Test experiment"
      }

      json = Serialization.to_json(exp)

      assert is_binary(json)
      assert json =~ "test_exp"
      assert json =~ "gpt4"
      assert json =~ "run"
      assert json =~ "Test experiment"
    end

    test "encodes nested Experiment with reliability config" do
      exp = %Experiment{
        id: :complex_exp,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}],
        reliability: %Config{
          ensemble: %Ensemble{strategy: :majority, execution_mode: :parallel},
          hedging: %Hedging{strategy: :fixed, delay_ms: 100},
          stats: %Stats{alpha: 0.01, tests: [:ttest]}
        }
      }

      json = Serialization.to_json(exp)

      assert is_binary(json)
      assert json =~ "complex_exp"
      assert json =~ "majority"
      assert json =~ "parallel"
      assert json =~ "fixed"
      assert json =~ "0.01"
      assert json =~ "ttest"
    end

    test "encodes Ensemble config to JSON" do
      ensemble = %Ensemble{strategy: :weighted, models: [:gpt4, :claude]}
      json = Serialization.to_json(ensemble)

      assert is_binary(json)
      assert json =~ "weighted"
      assert json =~ "gpt4"
      assert json =~ "claude"
    end
  end

  describe "from_json/2 for BackendRef" do
    test "decodes JSON to BackendRef" do
      json = ~s({"id":"gpt4","profile":"default"})
      {:ok, backend} = Serialization.from_json(json, BackendRef)

      assert %BackendRef{} = backend
      assert backend.id == :gpt4
      assert backend.profile == :default
    end

    test "decodes JSON with options" do
      json = ~s({"id":"gpt4","profile":"fast","options":{"temperature":0.7}})
      {:ok, backend} = Serialization.from_json(json, BackendRef)

      assert backend.options == %{"temperature" => 0.7}
    end
  end

  describe "from_json/2 for StageDef" do
    test "decodes JSON to StageDef" do
      json = ~s({"name":"inference","enabled":true})
      {:ok, stage} = Serialization.from_json(json, StageDef)

      assert %StageDef{} = stage
      assert stage.name == :inference
      assert stage.enabled == true
    end

    test "decodes JSON with options" do
      json = ~s({"name":"preprocessing","enabled":false,"options":{"normalize":true}})
      {:ok, stage} = Serialization.from_json(json, StageDef)

      assert stage.name == :preprocessing
      assert stage.enabled == false
      assert stage.options == %{"normalize" => true}
    end
  end

  describe "from_json/2 for DatasetRef" do
    test "decodes JSON to DatasetRef with atom name" do
      json = ~s({"name":"mmlu","provider":"crucible_datasets"})
      {:ok, dataset} = Serialization.from_json(json, DatasetRef)

      assert %DatasetRef{} = dataset
      assert dataset.name == :mmlu
      assert dataset.provider == :crucible_datasets
    end

    test "decodes JSON to DatasetRef with string name" do
      json = ~s({"name":"Custom Dataset 2024","provider":"custom"})
      {:ok, dataset} = Serialization.from_json(json, DatasetRef)

      assert dataset.name == "Custom Dataset 2024"
    end
  end

  describe "from_json/2 for Backend Prompt" do
    test "decodes JSON to Prompt" do
      json =
        ~s({"messages":[{"role":"user","content":"Hello"}],"options":{"model":"gpt-4o","stream":true}})

      {:ok, prompt} = Serialization.from_json(json, Prompt)

      assert %Prompt{} = prompt
      assert hd(prompt.messages).role == :user
      assert hd(prompt.messages).content == "Hello"
      assert prompt.options.model == "gpt-4o"
      assert prompt.options.stream == true
    end
  end

  describe "from_json/2 for Backend Options" do
    test "decodes JSON to Options" do
      json = ~s({"model":"gpt-4o","temperature":0.2,"response_format":"json"})
      {:ok, options} = Serialization.from_json(json, Options)

      assert %Options{} = options
      assert options.model == "gpt-4o"
      assert options.temperature == 0.2
      assert options.response_format == :json
    end
  end

  describe "from_json/2 for Backend Completion" do
    test "decodes JSON to Completion" do
      json =
        ~s({"model":"gpt-4o","choices":[{"index":0,"message":{"role":"assistant","content":"Hi"},"finish_reason":"stop"}]})

      {:ok, completion} = Serialization.from_json(json, Completion)

      assert %Completion{} = completion
      assert completion.model == "gpt-4o"
      assert hd(completion.choices).finish_reason == :stop
      assert hd(completion.choices).message.role == :assistant
    end
  end

  describe "from_json/2 for Backend Capabilities" do
    test "decodes JSON to Capabilities" do
      json =
        ~s({"backend_id":"openai","provider":"openai","models":["gpt-4o"],"supports_streaming":true})

      {:ok, caps} = Serialization.from_json(json, Capabilities)

      assert %Capabilities{} = caps
      assert caps.backend_id == :openai
      assert caps.provider == "openai"
      assert caps.models == ["gpt-4o"]
      assert caps.supports_streaming == true
    end
  end

  describe "from_json/2 for Experiment" do
    test "decodes simple experiment from JSON" do
      json = ~s({
        "id":"test_exp",
        "backend":{"id":"gpt4","profile":"default"},
        "pipeline":[{"name":"run","enabled":true}],
        "description":"Test"
      })

      {:ok, exp} = Serialization.from_json(json, Experiment)

      assert %Experiment{} = exp
      assert exp.id == :test_exp
      assert exp.backend.id == :gpt4
      assert length(exp.pipeline) == 1
      assert hd(exp.pipeline).name == :run
      assert exp.description == "Test"
    end

    test "decodes experiment with nested reliability config" do
      json = ~s({
        "id":"complex_exp",
        "backend":{"id":"gpt4"},
        "pipeline":[{"name":"run"}],
        "reliability":{
          "ensemble":{"strategy":"majority","execution_mode":"parallel"},
          "hedging":{"strategy":"fixed","delay_ms":100},
          "stats":{"alpha":0.01,"tests":["ttest"]}
        }
      })

      {:ok, exp} = Serialization.from_json(json, Experiment)

      assert exp.reliability.ensemble.strategy == :majority
      assert exp.reliability.ensemble.execution_mode == :parallel
      assert exp.reliability.hedging.strategy == :fixed
      assert exp.reliability.hedging.delay_ms == 100
      assert exp.reliability.stats.alpha == 0.01
      assert exp.reliability.stats.tests == [:ttest]
    end
  end

  describe "from_json/2 for Ensemble" do
    test "decodes Ensemble from JSON" do
      json = ~s({"strategy":"weighted","execution_mode":"sequential","models":["gpt4","claude"]})
      {:ok, ensemble} = Serialization.from_json(json, Ensemble)

      assert %Ensemble{} = ensemble
      assert ensemble.strategy == :weighted
      assert ensemble.execution_mode == :sequential
      assert ensemble.models == [:gpt4, :claude]
    end
  end

  describe "from_json/2 for Hedging" do
    test "decodes Hedging from JSON" do
      json = ~s({"strategy":"percentile","delay_ms":50,"percentile":0.95})
      {:ok, hedging} = Serialization.from_json(json, Hedging)

      assert %Hedging{} = hedging
      assert hedging.strategy == :percentile
      assert hedging.delay_ms == 50
      assert hedging.percentile == 0.95
    end
  end

  describe "from_json/2 for Stats" do
    test "decodes Stats from JSON" do
      json = ~s({"alpha":0.05,"tests":["ttest","bootstrap"],"confidence_level":0.95})
      {:ok, stats} = Serialization.from_json(json, Stats)

      assert %Stats{} = stats
      assert stats.alpha == 0.05
      assert stats.tests == [:ttest, :bootstrap]
      assert stats.confidence_level == 0.95
    end
  end

  describe "from_json/2 error handling" do
    test "returns error for invalid JSON" do
      assert {:error, _} = Serialization.from_json("invalid json", BackendRef)
    end

    test "returns error for missing required fields" do
      json = ~s({"profile":"default"})
      assert {:error, _} = Serialization.from_json(json, BackendRef)
    end
  end

  describe "from_map/2" do
    test "converts map with string keys to BackendRef" do
      map = %{"id" => "gpt4", "profile" => "default"}
      {:ok, backend} = Serialization.from_map(map, BackendRef)

      assert %BackendRef{} = backend
      assert backend.id == :gpt4
      assert backend.profile == :default
    end

    test "converts map with atom keys to BackendRef" do
      map = %{id: :gpt4, profile: :fast}
      {:ok, backend} = Serialization.from_map(map, BackendRef)

      assert backend.id == :gpt4
      assert backend.profile == :fast
    end

    test "converts map to Backend Prompt" do
      map = %{
        "messages" => [%{"role" => "user", "content" => "Hello"}],
        "options" => %{"model" => "gpt-4o"}
      }

      {:ok, prompt} = Serialization.from_map(map, Prompt)

      assert %Prompt{} = prompt
      assert hd(prompt.messages).role == :user
      assert prompt.options.model == "gpt-4o"
    end

    test "converts map to Backend Capabilities" do
      map = %{"backend_id" => "openai", "provider" => "openai", "models" => ["gpt-4o"]}
      {:ok, caps} = Serialization.from_map(map, Capabilities)

      assert %Capabilities{} = caps
      assert caps.backend_id == :openai
      assert caps.models == ["gpt-4o"]
    end

    test "converts nested maps to Experiment" do
      map = %{
        "id" => "test",
        "backend" => %{"id" => "gpt4"},
        "pipeline" => [%{"name" => "run"}]
      }

      {:ok, exp} = Serialization.from_map(map, Experiment)

      assert %Experiment{} = exp
      assert exp.id == :test
      assert exp.backend.id == :gpt4
      assert hd(exp.pipeline).name == :run
    end

    test "handles deeply nested reliability config" do
      map = %{
        "id" => "test",
        "backend" => %{"id" => "gpt4"},
        "pipeline" => [%{"name" => "run"}],
        "reliability" => %{
          "ensemble" => %{"strategy" => "majority"},
          "stats" => %{"alpha" => 0.01}
        }
      }

      {:ok, exp} = Serialization.from_map(map, Experiment)

      assert exp.reliability.ensemble.strategy == :majority
      assert exp.reliability.stats.alpha == 0.01
    end
  end

  describe "round-trip serialization" do
    test "BackendRef round-trip preserves data" do
      original = %BackendRef{id: :gpt4, profile: :fast, options: %{temp: 0.7}}
      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, BackendRef)

      assert decoded.id == original.id
      assert decoded.profile == original.profile
    end

    test "Backend Prompt round-trip preserves data" do
      original = %Prompt{
        messages: [%{role: :user, content: "Hello"}],
        options: %Options{model: "gpt-4o", stream: true}
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Prompt)

      assert hd(decoded.messages).role == :user
      assert decoded.options.model == "gpt-4o"
      assert decoded.options.stream == true
    end

    test "Backend Completion round-trip preserves data" do
      original = %Completion{
        model: "gpt-4o",
        choices: [
          %{index: 0, message: %{role: :assistant, content: "Hi"}, finish_reason: :stop}
        ]
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Completion)

      assert decoded.model == original.model
      assert hd(decoded.choices).finish_reason == :stop
      assert hd(decoded.choices).message.role == :assistant
    end

    test "Backend Capabilities round-trip preserves data" do
      original = %Capabilities{
        backend_id: :openai,
        provider: "openai",
        models: ["gpt-4o"],
        supports_vision: true
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Capabilities)

      assert decoded.backend_id == original.backend_id
      assert decoded.provider == original.provider
      assert decoded.supports_vision == true
    end

    test "Experiment round-trip preserves structure" do
      original = %Experiment{
        id: :test,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}],
        description: "Test",
        tags: [:ml, :test]
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Experiment)

      assert decoded.id == original.id
      assert decoded.backend.id == original.backend.id
      assert decoded.description == original.description
      assert decoded.tags == original.tags
    end

    test "Complex experiment with reliability round-trip" do
      original = %Experiment{
        id: :complex,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :run}],
        reliability: %Config{
          ensemble: %Ensemble{strategy: :majority, models: [:gpt4, :claude]},
          hedging: %Hedging{strategy: :fixed, delay_ms: 100},
          stats: %Stats{alpha: 0.01}
        }
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Experiment)

      assert decoded.id == original.id
      assert decoded.reliability.ensemble.strategy == :majority
      assert decoded.reliability.ensemble.models == [:gpt4, :claude]
      assert decoded.reliability.hedging.strategy == :fixed
      assert decoded.reliability.stats.alpha == 0.01
    end

    test "StageDef round-trip preserves options" do
      original = %StageDef{
        name: :preprocessing,
        enabled: false,
        options: %{"normalize" => true, "steps" => ["trim"]}
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, StageDef)

      assert decoded.name == original.name
      assert decoded.enabled == original.enabled
      assert decoded.options == original.options
    end

    test "DatasetRef round-trip preserves fields" do
      original = %DatasetRef{
        name: "Custom Dataset 2025",
        provider: :custom,
        split: :validation,
        version: "v2",
        format: :parquet,
        schema: %{"fields" => ["id", "text"]},
        options: %{"limit" => 10}
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, DatasetRef)

      assert decoded.name == original.name
      assert decoded.provider == original.provider
      assert decoded.split == original.split
      assert decoded.format == original.format
      assert decoded.schema == original.schema
      assert decoded.options == original.options
    end

    test "OutputSpec round-trip preserves fields" do
      original = %OutputSpec{
        name: :results,
        formats: [:json, :csv],
        sink: :s3,
        options: %{"path" => "/tmp/results"}
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, OutputSpec)

      assert decoded.name == original.name
      assert decoded.formats == original.formats
      assert decoded.sink == original.sink
      assert decoded.options == original.options
    end

    test "Reliability.Config round-trip preserves nested configs" do
      original = %Config{
        ensemble: %Ensemble{
          strategy: :weighted,
          execution_mode: :parallel,
          models: [:gpt4, :claude],
          weights: %{gpt4: 0.6, claude: 0.4},
          timeout_ms: 3_000
        },
        hedging: %Hedging{strategy: :percentile, delay_ms: 100, percentile: 0.95},
        stats: %Stats{alpha: 0.01, tests: [:ttest]},
        fairness: %Fairness{
          enabled: true,
          metrics: [:demographic_parity],
          group_by: :gender,
          threshold: 0.8,
          fail_on_violation: true,
          options: %{"mode" => "strict"}
        },
        guardrails: %Guardrail{profiles: [:strict], pii_detection: true},
        feedback: %Feedback.Config{enabled: true, sampling_rate: 0.1, storage: :s3}
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Config)

      assert decoded.ensemble.strategy == :weighted
      assert decoded.ensemble.weights == %{gpt4: 0.6, claude: 0.4}
      assert decoded.hedging.strategy == :percentile
      assert decoded.stats.tests == [:ttest]
      assert decoded.fairness.group_by == :gender
      assert decoded.guardrails.profiles == [:strict]
      assert decoded.feedback.storage == :s3
    end

    test "ModelRef round-trip preserves fields" do
      original = sample_model_ref()

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, ModelRef)

      assert decoded.id == original.id
      assert decoded.provider == original.provider
      assert decoded.framework == original.framework
      assert decoded.architecture == original.architecture
      assert decoded.task == original.task
      assert decoded.artifact_uri == original.artifact_uri
      assert decoded.metadata == original.metadata
    end

    test "ModelVersion round-trip preserves fields" do
      original = sample_model_version()

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, ModelVersion)

      assert decoded.id == original.id
      assert decoded.model_id == original.model_id
      assert decoded.version == original.version
      assert decoded.stage == original.stage
      assert decoded.created_at == original.created_at
    end

    test "Training.Config round-trip preserves nested references" do
      original = sample_training_config()

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Training.Config)

      assert decoded.id == original.id
      assert decoded.model_ref.id == original.model_ref.id
      assert decoded.dataset_ref.name == original.dataset_ref.name
      assert decoded.optimizer == original.optimizer
      assert decoded.device == original.device
    end

    test "Training.Run round-trip preserves fields" do
      training_config = sample_training_config()

      original = %Training.Run{
        id: :run_001,
        config: training_config,
        status: :running,
        current_epoch: 2,
        metrics_history: [%{"loss" => 0.5}],
        best_metrics: %{"loss" => 0.4},
        checkpoint_uris: ["s3://checkpoints/run_001.pt"],
        final_model_version: :gpt2_v1,
        started_at: ~U[2025-12-26 12:00:00Z],
        completed_at: nil,
        error_message: nil,
        options: %{"priority" => "high"}
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Training.Run)

      assert decoded.id == original.id
      assert decoded.status == original.status
      assert decoded.current_epoch == original.current_epoch
      assert decoded.started_at == original.started_at
      assert decoded.final_model_version == original.final_model_version
    end

    test "Deployment.Config round-trip preserves fields" do
      original = %Deployment.Config{
        id: :deploy_prod,
        model_version_id: :gpt2_v1,
        replicas: 2,
        environment: :production,
        strategy: :canary,
        target: %{"cluster" => "prod"},
        resources: %{"cpu" => "2"},
        scaling: %{"min" => 2},
        health_check: %{"path" => "/health"},
        endpoint: %{"path" => "/v1"},
        metadata: %{"team" => "mlops"},
        options: %{"note" => "test"}
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Deployment.Config)

      assert decoded.id == original.id
      assert decoded.model_version_id == original.model_version_id
      assert decoded.environment == original.environment
      assert decoded.strategy == original.strategy
      assert decoded.endpoint == original.endpoint
    end

    test "Deployment.Status round-trip preserves fields" do
      original = %Deployment.Status{
        id: :status_001,
        deployment_id: :deploy_prod,
        state: :active,
        ready_replicas: 2,
        total_replicas: 3,
        endpoint_url: "https://api.example.com",
        traffic_percent: 80.0,
        health: :healthy,
        last_health_check: ~U[2025-12-26 12:05:00Z],
        error_message: nil,
        created_at: ~U[2025-12-26 12:00:00Z],
        updated_at: ~U[2025-12-26 12:10:00Z]
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Deployment.Status)

      assert decoded.id == original.id
      assert decoded.deployment_id == original.deployment_id
      assert decoded.state == original.state
      assert decoded.health == original.health
      assert decoded.last_health_check == original.last_health_check
      assert decoded.updated_at == original.updated_at
    end

    test "Feedback.Config round-trip preserves fields" do
      original = %Feedback.Config{
        enabled: true,
        sampling_rate: 0.2,
        feedback_types: [:thumbs, :rating],
        storage: :s3,
        retention_days: 30,
        anonymize_pii: false,
        drift_detection: %{"window" => 7},
        retraining_trigger: %{"threshold" => 0.1},
        options: %{"bucket" => "feedback"}
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Feedback.Config)

      assert decoded.enabled == original.enabled
      assert decoded.sampling_rate == original.sampling_rate
      assert decoded.feedback_types == original.feedback_types
      assert decoded.storage == original.storage
      assert decoded.drift_detection == original.drift_detection
    end

    test "Feedback.Event round-trip preserves fields" do
      original = %Feedback.Event{
        id: "evt_123",
        deployment_id: :deploy_prod,
        model_version: "1.0.0",
        input: %{"prompt" => "hi"},
        output: %{"text" => "hello"},
        feedback_type: :thumbs,
        feedback_value: :up,
        user_id: "user_1",
        session_id: "sess_1",
        latency_ms: 120,
        timestamp: ~U[2025-12-26 12:00:00Z],
        metadata: %{"lang" => "en"}
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Feedback.Event)

      assert decoded.id == original.id
      assert decoded.deployment_id == original.deployment_id
      assert decoded.feedback_type == original.feedback_type
      assert decoded.timestamp == original.timestamp
      assert decoded.metadata == original.metadata
    end

    test "Experiment round-trip preserves model lifecycle fields" do
      model_ref = sample_model_ref()
      training_config = sample_training_config()
      model_version = sample_model_version()

      original = %Experiment{
        id: :training_exp,
        backend: %BackendRef{id: :gpt4},
        pipeline: [%StageDef{name: :train}],
        experiment_type: :training,
        model_version: model_version,
        training_config: training_config,
        baseline: model_ref,
        outputs: [%OutputSpec{name: :results, formats: [:json]}]
      }

      json = Serialization.to_json(original)
      {:ok, decoded} = Serialization.from_json(json, Experiment)

      assert decoded.experiment_type == original.experiment_type
      assert decoded.model_version.id == model_version.id
      assert decoded.training_config.id == training_config.id
      assert decoded.baseline.id == model_ref.id
      assert hd(decoded.outputs).formats == [:json]
    end
  end

  defp sample_model_ref do
    %ModelRef{
      id: :gpt2,
      name: "GPT-2",
      version: "1.0.0",
      provider: :huggingface,
      framework: :pytorch,
      architecture: :transformer,
      task: :text_generation,
      artifact_uri: "s3://models/gpt2",
      metadata: %{"license" => "mit"},
      options: %{"revision" => "main"}
    }
  end

  defp sample_dataset_ref do
    %DatasetRef{
      name: :wikitext,
      provider: :huggingface,
      split: :train,
      options: %{"limit" => 100}
    }
  end

  defp sample_training_config do
    %Training.Config{
      id: :train_gpt2,
      model_ref: sample_model_ref(),
      dataset_ref: sample_dataset_ref(),
      epochs: 5,
      batch_size: 16,
      learning_rate: 0.0005,
      optimizer: :adamw,
      loss_function: :cross_entropy,
      metrics: [:loss],
      validation_split: 0.1,
      device: :cuda,
      seed: 42,
      mixed_precision: true,
      gradient_clipping: 1.0,
      early_stopping: %{"patience" => 3},
      checkpoint_every: 100,
      options: %{"notes" => "fast"}
    }
  end

  defp sample_model_version do
    %ModelVersion{
      id: :gpt2_v1,
      model_id: :gpt2,
      version: "1.0.0",
      stage: :production,
      training_run_id: :run_001,
      metrics: %{"loss" => 0.1},
      artifact_uri: "s3://models/gpt2/v1",
      parent_version: "0.9.0",
      description: "baseline",
      created_at: ~U[2025-12-26 12:00:00Z],
      created_by: "mlops",
      options: %{"notes" => "promoted"}
    }
  end
end
