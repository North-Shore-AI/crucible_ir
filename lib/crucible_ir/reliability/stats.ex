defmodule CrucibleIR.Reliability.Stats do
  @moduledoc """
  Configuration for statistical testing and analysis.

  Controls which statistical tests are run, significance levels,
  and other analysis parameters.

  ## Fields

  - `:tests` - List of statistical tests to run (default: `[:ttest, :bootstrap]`)
  - `:alpha` - Significance level (default: `0.05`)
  - `:confidence_level` - Confidence level for intervals
  - `:effect_size_type` - Type of effect size to calculate
  - `:multiple_testing_correction` - Correction method for multiple tests
  - `:bootstrap_iterations` - Number of bootstrap iterations
  - `:options` - Additional statistics options

  ## Available Tests

  - `:ttest` - Student's t-test
  - `:bootstrap` - Bootstrap resampling
  - `:anova` - Analysis of variance
  - `:mannwhitney` - Mann-Whitney U test
  - `:wilcoxon` - Wilcoxon signed-rank test
  - `:kruskal` - Kruskal-Wallis test

  ## Effect Size Types

  - `:cohens_d` - Cohen's d
  - `:eta_squared` - η² (eta-squared)
  - `:omega_squared` - ω² (omega-squared)
  """

  @derive Jason.Encoder
  defstruct tests: [:ttest, :bootstrap],
            alpha: 0.05,
            confidence_level: nil,
            effect_size_type: nil,
            multiple_testing_correction: nil,
            bootstrap_iterations: nil,
            options: nil

  @type test ::
          :ttest | :bootstrap | :anova | :mannwhitney | :wilcoxon | :kruskal | atom()
  @type effect_size :: :cohens_d | :eta_squared | :omega_squared | atom()
  @type correction :: :bonferroni | :holm | :fdr | atom()

  @type t :: %__MODULE__{
          tests: [test()],
          alpha: float(),
          confidence_level: float() | nil,
          effect_size_type: effect_size() | nil,
          multiple_testing_correction: correction() | nil,
          bootstrap_iterations: pos_integer() | nil,
          options: map() | nil
        }
end
