defmodule Serv.Mixfile do
  use Mix.Project

  def project do
    [
      app: :serv,
      version: "0.1.2",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: description(), #
      package: package(),
      deps: deps(),
      name: "Database_serv",
      source_url: "https://github.com/Feo740/feo_kvstore"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      registered: [:database_app],
      mod: {D_apl, []},
      env: [cowboy_port: 8080],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.3.5"},
      {:ex_doc, ">= 0.0.0", only: :dev},
          #{:ex_doc, github: "elixir-lang/ex_doc"},
  #  {:markdown, github: "devinus/markdown"}
      #{:serv, "0.1.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description() do
    "Тестовое задание проект"
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "test", "doc", "deps", "config", "README.md"],
      maintainers: ["Feodor Terekhov"],
      licenses: ["OpenSource"],
      links: %{"GitHub" => "https://github.com/Feo740/feo_kvstore"}
    ]
  end


end
