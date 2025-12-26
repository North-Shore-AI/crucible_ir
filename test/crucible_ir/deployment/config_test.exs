defmodule CrucibleIR.Deployment.ConfigTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.Deployment.Config

  describe "struct creation" do
    test "creates with required fields" do
      config = %Config{
        id: :deploy_prod,
        model_version_id: :v1_0_0
      }

      assert config.id == :deploy_prod
      assert config.model_version_id == :v1_0_0
    end

    test "uses correct defaults" do
      config = %Config{
        id: :deploy,
        model_version_id: :v1
      }

      assert config.replicas == 1
      assert config.environment == :development
      assert config.strategy == :rolling
      assert config.target == nil
      assert config.resources == nil
      assert config.scaling == nil
      assert config.health_check == nil
      assert config.endpoint == nil
      assert config.metadata == nil
      assert config.options == nil
    end

    test "accepts all optional fields" do
      config = %Config{
        id: :deploy_prod,
        model_version_id: :v1_0_0,
        target: %{type: :kubernetes, cluster: "prod-cluster"},
        replicas: 3,
        resources: %{cpu: "2", memory: "4Gi", gpu: 1},
        scaling: %{min: 2, max: 10, target_cpu: 80},
        environment: :production,
        strategy: :blue_green,
        health_check: %{path: "/health", interval_seconds: 30},
        endpoint: %{path: "/predict", rate_limit: 1000},
        metadata: %{team: "ml-platform"},
        options: %{autoscale: true}
      }

      assert config.target == %{type: :kubernetes, cluster: "prod-cluster"}
      assert config.replicas == 3
      assert config.resources == %{cpu: "2", memory: "4Gi", gpu: 1}
      assert config.scaling == %{min: 2, max: 10, target_cpu: 80}
      assert config.environment == :production
      assert config.strategy == :blue_green
      assert config.health_check == %{path: "/health", interval_seconds: 30}
      assert config.endpoint == %{path: "/predict", rate_limit: 1000}
      assert config.metadata == %{team: "ml-platform"}
      assert config.options == %{autoscale: true}
    end
  end

  describe "environments" do
    test "supports development environment" do
      config = %Config{id: :deploy, model_version_id: :v1, environment: :development}
      assert config.environment == :development
    end

    test "supports staging environment" do
      config = %Config{id: :deploy, model_version_id: :v1, environment: :staging}
      assert config.environment == :staging
    end

    test "supports production environment" do
      config = %Config{id: :deploy, model_version_id: :v1, environment: :production}
      assert config.environment == :production
    end
  end

  describe "strategies" do
    test "supports rolling strategy" do
      config = %Config{id: :deploy, model_version_id: :v1, strategy: :rolling}
      assert config.strategy == :rolling
    end

    test "supports blue_green strategy" do
      config = %Config{id: :deploy, model_version_id: :v1, strategy: :blue_green}
      assert config.strategy == :blue_green
    end

    test "supports canary strategy" do
      config = %Config{id: :deploy, model_version_id: :v1, strategy: :canary}
      assert config.strategy == :canary
    end

    test "supports recreate strategy" do
      config = %Config{id: :deploy, model_version_id: :v1, strategy: :recreate}
      assert config.strategy == :recreate
    end
  end

  describe "scaling" do
    test "configures replicas" do
      config = %Config{id: :deploy, model_version_id: :v1, replicas: 5}
      assert config.replicas == 5
    end

    test "configures auto-scaling" do
      config = %Config{
        id: :deploy,
        model_version_id: :v1,
        scaling: %{
          min_replicas: 2,
          max_replicas: 10,
          target_cpu_utilization: 80
        }
      }

      assert config.scaling.min_replicas == 2
      assert config.scaling.max_replicas == 10
    end
  end

  describe "resources" do
    test "configures resource limits" do
      config = %Config{
        id: :deploy,
        model_version_id: :v1,
        resources: %{
          cpu: "4",
          memory: "8Gi",
          gpu: 2
        }
      }

      assert config.resources.cpu == "4"
      assert config.resources.memory == "8Gi"
      assert config.resources.gpu == 2
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      config = %Config{
        id: :deploy_prod,
        model_version_id: :v1_0_0,
        environment: :production,
        replicas: 3
      }

      json = Jason.encode!(config)

      assert is_binary(json)
      assert json =~ "deploy_prod"
      assert json =~ "v1_0_0"
      assert json =~ "production"
    end

    test "encodes nested maps" do
      config = %Config{
        id: :deploy,
        model_version_id: :v1,
        resources: %{cpu: "2", memory: "4Gi"}
      }

      json = Jason.encode!(config)

      assert json =~ "cpu"
      assert json =~ "memory"
      assert json =~ "4Gi"
    end
  end
end
