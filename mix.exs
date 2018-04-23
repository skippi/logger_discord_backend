defmodule LoggerDiscordBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :logger_discord_backend,
      version: "0.1.0",
      elixir: "~> 1.6",
      deps: deps(),

      # Hex

      description: description(),

      # Docs

      name: "LoggerDiscordBackend"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  defp description do
    "A logger backend that writes to a discord text channel."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.9.2"},
      {:ex_doc, "~> 0.18.3"},
      {:nostrum, git: "https://github.com/Kraigie/nostrum"}
    ]
  end
end
