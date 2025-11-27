defmodule CrucibleIR.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :crucible_ir,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      dialyzer: [plt_add_apps: [:mix]],
      deps: deps(),
      description: "Intermediate Representation for the Crucible ML reliability ecosystem",
      package: package(),
      docs: docs(),
      name: "CrucibleIR"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "Docs" => "https://hexdocs.pm/crucible_ir"
      },
      maintainers: ["North-Shore-AI"],
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "CHANGELOG.md",
        "LICENSE",
        "assets"
      ]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      assets: %{"assets" => "assets"},
      logo: "assets/crucible_ir.svg"
    ]
  end
end
