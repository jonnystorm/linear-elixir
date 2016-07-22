defmodule LinearEx.Mixfile do
  use Mix.Project

  def project do
    [app: :linear_ex,
     version: "0.0.3",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :jds_math_ex]]
  end

  defp deps do
    [
      {:jds_math_ex, git: "https://github.com/jonnystorm/jds-math-elixir"}
    ]
  end
end
