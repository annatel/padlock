defmodule Padlock.MixProject do
  use Mix.Project

  @source_url "https://github.com/annatel/padlock"
  @version "0.1.1"

  def project do
    [
      app: :padlock,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: test_coverage(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.6"},
      {:myxql, "~> 0.4.0", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp test_coverage() do
    [
      ignore_modules: [Padlock.Migrations, Padlock.Migrations.V1]
    ]
  end

  defp aliases do
    [
      test: ["ecto.setup", "test"],
      "ecto.setup": [
        "ecto.create --quiet -r Padlock.TestRepo",
        "ecto.migrate -r Padlock.TestRepo"
      ],
      "ecto.reset": ["ecto.drop -r Padlock.TestRepo", "ecto.setup"]
    ]
  end

  defp description() do
    "Record events"
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: [
        "README.md"
      ]
    ]
  end
end
