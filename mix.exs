defmodule Payjp.Mixfile do
  use Mix.Project

  def project do
    [app: :payjp,
     version: "0.1.4",
     elixir: "~> 1.4",
     description: description(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.detail": :test,
       "coveralls.post": :test,
       "coveralls.html": :test,
       vcr: :test,
       "vcr.delete": :test,
       "vcr.check": :test,
       "vcr.show": :test
     ],
     deps: deps]
  end

  # Configuration for the OTP application
  def application do
    [
      applications: [:httpoison]
    ]
  end

  defp deps do
    [
      {:httpoison, ">= 0.0.0" },
      {:poison, ">= 0.0.0", optional: true},
      {:retry, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev},
      {:excoveralls, ">= 0.0.0", only: :test},
      {:exvcr, ">= 0.0.0", only: [:test, :dev]},
      {:mock, ">= 0.0.0", only: :test},
      {:inch_ex, ">= 0.0.0", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    A PAY.JP Library for Elixir.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Shuhei Hayashibara"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/shufo/payjp-elixir",
        "Docs" => "https://hexdocs.pm/payjp"
      }
    ]
  end
end
