defmodule Noora.MixProject do
  use Mix.Project

  def project do
    [
      app: :noora,
      description: "A component library for Phoenix LiveView applications",
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7.12"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 1.0.0"}
    ]
  end

  defp package do
    [
      name: "noora",
      maintainers: ["Christoph Schmatzler", "Marek Fořt", "Pedro Piñera", "Asmit Malakannawar"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/tuist/noora"},
      files: [
        "lib",
        "https://github.com/tuist/noora",
        "mix.exs",
        "README.md",
        "LICENSE"
      ]
    ]
  end

  defp docs do
    [
      main: "Noora",
      extras: ["CHANGELOD.md"]
    ]
  end
end
