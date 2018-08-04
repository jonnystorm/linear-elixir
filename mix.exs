defmodule Linear.Mixfile do
  use Mix.Project

  def project do
    [ app: :linear_ex,
      version: "0.0.4",
      name: "LinearEx",
      source_url: "https://github.com/jonnystorm/linear-elixir",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      docs: [extras: ["README.md"]],
      dialyzer: [
        add_plt_apps: [
          :logger,
          :jds_math_ex,
        ],
        ignore_warnings: "dialyzer.ignore",
        flags: [
          :unmatched_returns,
          :error_handling,
          :race_conditions,
          :underspecs,
        ],
      ],
    ]
  end

  def application do
    [ applications: [
        :logger,
        :jds_math_ex
      ]
    ]
  end

  defp deps do
    [ {:jds_math_ex, git: "https://gitlab.com/jonnystorm/jds-math-elixir"},
    ]
  end
end
