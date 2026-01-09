# CrucibleIR Examples

These examples are data-only IR definitions. They do not execute pipelines or make
network calls. Downstream packages (crucible_framework, adapters, or domain
services) interpret the IR and perform the actual API requests.

## Running the examples

From the repo root:

```bash
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
```

## Accounts and API keys

These integrations are referenced in the IR. Make sure the downstream runtime
has the required accounts and keys configured. Do not store secrets in IR; pass
environment variable names in `options` or runtime configs instead.

### OpenAI

1. Create an account at https://platform.openai.com/
2. Create an API key.
3. Export the key for your runtime:

```bash
export OPENAI_API_KEY="your_key"
```

### Anthropic

1. Create an account at https://console.anthropic.com/
2. Create an API key.
3. Export the key for your runtime:

```bash
export ANTHROPIC_API_KEY="your_key"
```

### Hugging Face

1. Create an account at https://huggingface.co/
2. Create an access token.
3. Export the token for your runtime:

```bash
export HUGGINGFACE_TOKEN="your_token"
```

### AWS S3

1. Create an AWS account at https://aws.amazon.com/
2. Create an IAM user with S3 access.
3. Export credentials and region:

```bash
export AWS_ACCESS_KEY_ID="your_key_id"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_REGION="us-east-1"
```

### Google Cloud (GCS and BigQuery)

1. Create a project in https://console.cloud.google.com/
2. Enable Cloud Storage and BigQuery APIs.
3. Create a service account and download a JSON key.
4. Export credentials:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"
export GOOGLE_CLOUD_PROJECT="your_project_id"
```

### Postgres

1. Provision a Postgres instance.
2. Export a connection string for your runtime:

```bash
export DATABASE_URL="postgres://user:pass@host:5432/db"
```

### Crucible datasets

If you use the `crucible_datasets` provider, no external account is required by
this repo. If your org uses a private dataset service, configure its API key in
your runtime environment and reference it via `options`.

## Examples index

- `examples/01_backends_openai_anthropic.exs` - OpenAI and Anthropic backend refs with fallback and endpoint URL.
- `examples/02_dataset_providers.exs` - `crucible_datasets` and Hugging Face dataset refs.
- `examples/03_output_sinks.exs` - Output specs for file, stdout, S3, and Postgres sinks.
- `examples/04_model_registry_providers.exs` - Model refs for local, Hugging Face, OpenAI, Anthropic, S3, and GCS.
- `examples/05_training_and_run.exs` - Training config and training run records.
- `examples/06_deployment_config_and_status.exs` - Deployment config and deployment status.
- `examples/07_feedback_storage.exs` - Feedback configs for Postgres, S3, BigQuery, and local storage.
- `examples/08_reliability_and_guardrails.exs` - Reliability config with ensemble, hedging, stats, fairness, and guardrails.
- `examples/09_serialization_round_trip.exs` - JSON round-trip example using `CrucibleIR.Serialization`.
- `examples/10_backend_ir_contract.exs` - Backend prompt, completion, and capabilities IR examples.

## Notes

- Use string keys in `options` maps for stable JSON round-trip behavior.
- These files are meant for demonstration; tailor them to your adapters.
