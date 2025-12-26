defmodule CrucibleIR.Feedback.ConfigTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.Feedback.Config

  describe "struct creation" do
    test "creates with defaults only" do
      config = %Config{}

      assert config.enabled == false
      assert config.sampling_rate == 1.0
      assert config.feedback_types == [:thumbs, :correction]
      assert config.storage == :postgres
      assert config.anonymize_pii == true
      assert config.retention_days == nil
      assert config.drift_detection == nil
      assert config.retraining_trigger == nil
      assert config.options == nil
    end

    test "accepts all optional fields" do
      config = %Config{
        enabled: true,
        sampling_rate: 0.1,
        feedback_types: [:thumbs, :rating, :correction, :flag],
        storage: :s3,
        retention_days: 90,
        anonymize_pii: false,
        drift_detection: %{
          enabled: true,
          threshold: 0.1,
          window_size: 1000
        },
        retraining_trigger: %{
          min_feedback_count: 1000,
          accuracy_threshold: 0.8
        },
        options: %{batch_size: 100}
      }

      assert config.enabled == true
      assert config.sampling_rate == 0.1
      assert length(config.feedback_types) == 4
      assert config.storage == :s3
      assert config.retention_days == 90
      assert config.anonymize_pii == false
      assert config.drift_detection.enabled == true
      assert config.retraining_trigger.min_feedback_count == 1000
      assert config.options == %{batch_size: 100}
    end
  end

  describe "sampling" do
    test "supports full sampling (1.0)" do
      config = %Config{sampling_rate: 1.0}
      assert config.sampling_rate == 1.0
    end

    test "supports no sampling (0.0)" do
      config = %Config{sampling_rate: 0.0}
      assert config.sampling_rate == 0.0
    end

    test "supports partial sampling (0.1)" do
      config = %Config{sampling_rate: 0.1}
      assert config.sampling_rate == 0.1
    end
  end

  describe "feedback types" do
    test "supports thumbs feedback" do
      config = %Config{feedback_types: [:thumbs]}
      assert :thumbs in config.feedback_types
    end

    test "supports rating feedback" do
      config = %Config{feedback_types: [:rating]}
      assert :rating in config.feedback_types
    end

    test "supports correction feedback" do
      config = %Config{feedback_types: [:correction]}
      assert :correction in config.feedback_types
    end

    test "supports multiple feedback types" do
      config = %Config{feedback_types: [:thumbs, :rating, :correction, :label, :flag]}
      assert length(config.feedback_types) == 5
    end
  end

  describe "storage" do
    test "supports postgres storage" do
      config = %Config{storage: :postgres}
      assert config.storage == :postgres
    end

    test "supports s3 storage" do
      config = %Config{storage: :s3}
      assert config.storage == :s3
    end

    test "supports bigquery storage" do
      config = %Config{storage: :bigquery}
      assert config.storage == :bigquery
    end

    test "supports local storage" do
      config = %Config{storage: :local}
      assert config.storage == :local
    end
  end

  describe "privacy" do
    test "anonymize_pii defaults to true" do
      config = %Config{}
      assert config.anonymize_pii == true
    end

    test "can disable PII anonymization" do
      config = %Config{anonymize_pii: false}
      assert config.anonymize_pii == false
    end
  end

  describe "retention" do
    test "tracks retention days" do
      config = %Config{retention_days: 365}
      assert config.retention_days == 365
    end

    test "retention is nil by default" do
      config = %Config{}
      assert config.retention_days == nil
    end
  end

  describe "drift detection" do
    test "configures drift detection" do
      config = %Config{
        drift_detection: %{
          enabled: true,
          method: :psi,
          threshold: 0.1,
          window_size: 1000,
          alert_on_drift: true
        }
      }

      assert config.drift_detection.enabled == true
      assert config.drift_detection.method == :psi
      assert config.drift_detection.threshold == 0.1
    end
  end

  describe "retraining triggers" do
    test "configures retraining trigger" do
      config = %Config{
        retraining_trigger: %{
          enabled: true,
          min_feedback_count: 10000,
          accuracy_threshold: 0.75,
          check_interval_hours: 24
        }
      }

      assert config.retraining_trigger.enabled == true
      assert config.retraining_trigger.min_feedback_count == 10000
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      config = %Config{
        enabled: true,
        sampling_rate: 0.5,
        feedback_types: [:thumbs, :rating]
      }

      json = Jason.encode!(config)

      assert is_binary(json)
      assert json =~ "true"
      assert json =~ "0.5"
      assert json =~ "thumbs"
      assert json =~ "rating"
    end

    test "encodes nested configs" do
      config = %Config{
        drift_detection: %{enabled: true, threshold: 0.1}
      }

      json = Jason.encode!(config)

      assert json =~ "drift_detection"
      assert json =~ "threshold"
      assert json =~ "0.1"
    end
  end
end
