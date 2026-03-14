defmodule Ldif.MixProject do
  use Mix.Project

  def project do
    [
      app: :ldif,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "readme",
        #logo: "logo.png",
        extras: ["README.md", "LICENSE"]
      ],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5"},
      {:curl_req, "~> 0.98.0"},
      {:recase, "~> 0.9"},

      {:apex, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14 and >= 0.14.4", only: [:dev, :test]},
      {:benchee, "~> 1.3", only: [:dev, :test]},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:earmark, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:doctor, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
