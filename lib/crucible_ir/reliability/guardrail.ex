defmodule CrucibleIR.Reliability.Guardrail do
  @moduledoc """
  Configuration for LLM guardrails and security.

  Controls prompt injection detection, PII protection, and other
  safety measures for LLM applications.

  ## Fields

  - `:profiles` - Security profiles to use (default: `[:default]`)
  - `:prompt_injection_detection` - Detect prompt injection attempts
  - `:jailbreak_detection` - Detect jailbreak attempts
  - `:pii_detection` - Detect personally identifiable information
  - `:pii_redaction` - Redact detected PII
  - `:content_moderation` - Moderate content for safety
  - `:fail_on_detection` - Whether to fail when threats detected
  - `:options` - Additional guardrail options

  ## Security Profiles

  - `:default` - Standard security measures
  - `:strict` - High security, may have false positives
  - `:moderate` - Balanced security and usability
  - `:permissive` - Minimal restrictions
  """

  @derive Jason.Encoder
  defstruct profiles: [:default],
            prompt_injection_detection: nil,
            jailbreak_detection: nil,
            pii_detection: nil,
            pii_redaction: nil,
            content_moderation: nil,
            fail_on_detection: nil,
            options: nil

  @type profile :: :default | :strict | :moderate | :permissive | atom()

  @type t :: %__MODULE__{
          profiles: [profile()],
          prompt_injection_detection: boolean() | nil,
          jailbreak_detection: boolean() | nil,
          pii_detection: boolean() | nil,
          pii_redaction: boolean() | nil,
          content_moderation: boolean() | nil,
          fail_on_detection: boolean() | nil,
          options: map() | nil
        }
end
