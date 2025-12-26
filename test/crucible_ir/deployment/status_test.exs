defmodule CrucibleIR.Deployment.StatusTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.Deployment.Status

  describe "struct creation" do
    test "creates with required fields" do
      status = %Status{
        id: :status_001,
        deployment_id: :deploy_prod
      }

      assert status.id == :status_001
      assert status.deployment_id == :deploy_prod
    end

    test "uses correct defaults" do
      status = %Status{
        id: :status_001,
        deployment_id: :deploy_prod
      }

      assert status.state == :pending
      assert status.health == :unknown
      assert status.ready_replicas == nil
      assert status.total_replicas == nil
      assert status.endpoint_url == nil
      assert status.traffic_percent == nil
      assert status.last_health_check == nil
      assert status.error_message == nil
      assert status.created_at == nil
      assert status.updated_at == nil
    end

    test "accepts all optional fields" do
      now = DateTime.utc_now()

      status = %Status{
        id: :status_001,
        deployment_id: :deploy_prod,
        state: :active,
        ready_replicas: 3,
        total_replicas: 3,
        endpoint_url: "https://api.example.com/predict",
        traffic_percent: 100.0,
        health: :healthy,
        last_health_check: now,
        error_message: nil,
        created_at: now,
        updated_at: now
      }

      assert status.state == :active
      assert status.ready_replicas == 3
      assert status.total_replicas == 3
      assert status.endpoint_url == "https://api.example.com/predict"
      assert status.traffic_percent == 100.0
      assert status.health == :healthy
      assert status.last_health_check == now
      assert status.created_at == now
      assert status.updated_at == now
    end
  end

  describe "states" do
    test "supports pending state" do
      status = %Status{id: :s, deployment_id: :d, state: :pending}
      assert status.state == :pending
    end

    test "supports deploying state" do
      status = %Status{id: :s, deployment_id: :d, state: :deploying}
      assert status.state == :deploying
    end

    test "supports active state" do
      status = %Status{id: :s, deployment_id: :d, state: :active}
      assert status.state == :active
    end

    test "supports degraded state" do
      status = %Status{id: :s, deployment_id: :d, state: :degraded}
      assert status.state == :degraded
    end

    test "supports failed state" do
      status = %Status{
        id: :s,
        deployment_id: :d,
        state: :failed,
        error_message: "Container crashed"
      }

      assert status.state == :failed
      assert status.error_message == "Container crashed"
    end

    test "supports terminated state" do
      status = %Status{id: :s, deployment_id: :d, state: :terminated}
      assert status.state == :terminated
    end
  end

  describe "health" do
    test "supports unknown health" do
      status = %Status{id: :s, deployment_id: :d, health: :unknown}
      assert status.health == :unknown
    end

    test "supports healthy health" do
      status = %Status{id: :s, deployment_id: :d, health: :healthy}
      assert status.health == :healthy
    end

    test "supports unhealthy health" do
      status = %Status{id: :s, deployment_id: :d, health: :unhealthy}
      assert status.health == :unhealthy
    end

    test "supports degraded health" do
      status = %Status{id: :s, deployment_id: :d, health: :degraded}
      assert status.health == :degraded
    end
  end

  describe "replica tracking" do
    test "tracks ready vs total replicas" do
      status = %Status{
        id: :s,
        deployment_id: :d,
        ready_replicas: 2,
        total_replicas: 3
      }

      assert status.ready_replicas == 2
      assert status.total_replicas == 3
    end

    test "all replicas ready when ready equals total" do
      status = %Status{
        id: :s,
        deployment_id: :d,
        ready_replicas: 3,
        total_replicas: 3
      }

      assert status.ready_replicas == status.total_replicas
    end
  end

  describe "traffic routing" do
    test "tracks traffic percentage" do
      status = %Status{
        id: :s,
        deployment_id: :d,
        traffic_percent: 50.0
      }

      assert status.traffic_percent == 50.0
    end

    test "supports full traffic" do
      status = %Status{
        id: :s,
        deployment_id: :d,
        traffic_percent: 100.0
      }

      assert status.traffic_percent == 100.0
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      status = %Status{
        id: :status_001,
        deployment_id: :deploy_prod,
        state: :active,
        health: :healthy
      }

      json = Jason.encode!(status)

      assert is_binary(json)
      assert json =~ "status_001"
      assert json =~ "deploy_prod"
      assert json =~ "active"
      assert json =~ "healthy"
    end

    test "encodes endpoint URL" do
      status = %Status{
        id: :s,
        deployment_id: :d,
        endpoint_url: "https://api.example.com/v1/predict"
      }

      json = Jason.encode!(status)

      assert json =~ "endpoint_url"
      assert json =~ "https://api.example.com/v1/predict"
    end
  end
end
