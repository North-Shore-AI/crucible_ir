#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$root_dir"

mix run examples/01_backends_openai_anthropic.exs
mix run examples/02_dataset_providers.exs
mix run examples/03_output_sinks.exs
mix run examples/04_model_registry_providers.exs
mix run examples/05_training_and_run.exs
mix run examples/06_deployment_config_and_status.exs
mix run examples/07_feedback_storage.exs
mix run examples/08_reliability_and_guardrails.exs
mix run examples/09_serialization_round_trip.exs
mix run examples/10_backend_ir_contract.exs
