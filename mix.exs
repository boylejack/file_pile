defmodule FilePile.Mixfile do
  use Mix.Project

  def project do
    [app: :file_pile,
     version: "0.1.0",
     elixir: "~> 1.3",
     escript: escript_config,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :bunt, :sizeable]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:csv, "~> 1.4.2"},
      {:uuid, "~> 1.1"},
      {:bunt, "~> 0.1.0"},
      {:sizeable, "~> 0.1.5"}
    ]
  end

  defp escript_config do
    [main_module: FilePile]
  end
end
