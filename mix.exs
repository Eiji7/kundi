defmodule Kundi.MixProject do
  use Mix.Project

  def application do
    [extra_applications: [:logger], mod: {Kundi.Application, []}]
  end

  def project do
    [
      app: :kundi,
      deps: [{:plug_cowboy, "~> 2.0"}],
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      version: "1.0.0"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
