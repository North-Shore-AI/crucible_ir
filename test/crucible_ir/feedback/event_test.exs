defmodule CrucibleIR.Feedback.EventTest do
  use ExUnit.Case, async: true

  alias CrucibleIR.Feedback.Event

  describe "struct creation" do
    test "creates with required id field" do
      event = %Event{id: "evt_123"}
      assert event.id == "evt_123"
    end

    test "uses correct defaults" do
      event = %Event{id: "evt_123"}

      assert event.feedback_type == :thumbs
      assert event.timestamp == nil
      assert event.deployment_id == nil
      assert event.model_version == nil
      assert event.input == nil
      assert event.output == nil
      assert event.feedback_value == nil
      assert event.user_id == nil
      assert event.session_id == nil
      assert event.latency_ms == nil
      assert event.metadata == nil
    end

    test "accepts all optional fields" do
      now = DateTime.utc_now()

      event = %Event{
        id: "evt_123",
        deployment_id: :deploy_prod,
        model_version: "1.0.0",
        input: %{prompt: "What is 2+2?"},
        output: %{response: "4"},
        feedback_type: :rating,
        feedback_value: 5,
        user_id: "user_456",
        session_id: "sess_789",
        latency_ms: 150,
        timestamp: now,
        metadata: %{source: "web"}
      }

      assert event.deployment_id == :deploy_prod
      assert event.model_version == "1.0.0"
      assert event.input == %{prompt: "What is 2+2?"}
      assert event.output == %{response: "4"}
      assert event.feedback_type == :rating
      assert event.feedback_value == 5
      assert event.user_id == "user_456"
      assert event.session_id == "sess_789"
      assert event.latency_ms == 150
      assert event.timestamp == now
      assert event.metadata == %{source: "web"}
    end
  end

  describe "feedback types" do
    test "supports thumbs feedback" do
      event = %Event{id: "e1", feedback_type: :thumbs, feedback_value: :up}
      assert event.feedback_type == :thumbs
      assert event.feedback_value == :up
    end

    test "supports rating feedback" do
      event = %Event{id: "e1", feedback_type: :rating, feedback_value: 5}
      assert event.feedback_type == :rating
      assert event.feedback_value == 5
    end

    test "supports correction feedback" do
      event = %Event{
        id: "e1",
        feedback_type: :correction,
        feedback_value: %{original: "wrong", corrected: "right"}
      }

      assert event.feedback_type == :correction
      assert event.feedback_value.corrected == "right"
    end

    test "supports label feedback" do
      event = %Event{
        id: "e1",
        feedback_type: :label,
        feedback_value: %{label: "spam", confidence: 0.95}
      }

      assert event.feedback_type == :label
    end

    test "supports flag feedback" do
      event = %Event{
        id: "e1",
        feedback_type: :flag,
        feedback_value: %{reason: "inappropriate", severity: :high}
      }

      assert event.feedback_type == :flag
      assert event.feedback_value.reason == "inappropriate"
    end
  end

  describe "thumbs feedback values" do
    test "supports thumbs up" do
      event = %Event{id: "e1", feedback_type: :thumbs, feedback_value: :up}
      assert event.feedback_value == :up
    end

    test "supports thumbs down" do
      event = %Event{id: "e1", feedback_type: :thumbs, feedback_value: :down}
      assert event.feedback_value == :down
    end
  end

  describe "input/output tracking" do
    test "tracks input prompt" do
      event = %Event{
        id: "e1",
        input: %{prompt: "Explain machine learning", context: %{system: "You are helpful"}}
      }

      assert event.input.prompt == "Explain machine learning"
    end

    test "tracks output response" do
      event = %Event{
        id: "e1",
        output: %{response: "Machine learning is...", tokens_used: 100}
      }

      assert event.output.response == "Machine learning is..."
    end
  end

  describe "session tracking" do
    test "tracks user and session" do
      event = %Event{
        id: "e1",
        user_id: "user_123",
        session_id: "sess_456"
      }

      assert event.user_id == "user_123"
      assert event.session_id == "sess_456"
    end
  end

  describe "performance tracking" do
    test "tracks latency" do
      event = %Event{id: "e1", latency_ms: 250}
      assert event.latency_ms == 250
    end
  end

  describe "Jason encoding" do
    test "encodes to JSON" do
      event = %Event{
        id: "evt_123",
        feedback_type: :thumbs,
        feedback_value: :up
      }

      json = Jason.encode!(event)

      assert is_binary(json)
      assert json =~ "evt_123"
      assert json =~ "thumbs"
      assert json =~ "up"
    end

    test "encodes input/output" do
      event = %Event{
        id: "e1",
        input: %{prompt: "Hello"},
        output: %{response: "Hi there"}
      }

      json = Jason.encode!(event)

      assert json =~ "Hello"
      assert json =~ "Hi there"
    end
  end
end
