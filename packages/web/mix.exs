defmodule Noora.MixProject do
  use Mix.Project

  def project do
    [
      app: :noora,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
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
      {:phoenix_live_view, "~> 1.0.0"},
    ]
  end

  defp package do 
  [
      files: [
        "lib",
        "priv",
        "mix.exs",
        "README.md",
        "LICENSE"
      ],
      maintainers: ["Your Name"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/yourusername/your_library"}
    ]
  end
end
