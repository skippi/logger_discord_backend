# LoggerDiscordBackend

An elixir `Logger` backend that sends messages to discord.

Here is an example configuration file:

```elixir
config :nostrum,
  token: "discord_auth_token",
  num_shards: 1

config :logger,
  backends: [LoggerDiscordBackend],
  level: :debug

config :logger, LoggerDiscordBackend,
  level: :error,
  format: "```$date $time [$level] $message```",
  recipient_id: 351500354581692420
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `logger_discord_backend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logger_discord_backend, "~> 0.1.0"}
  ]
end
```

## Important Links

  * Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/logger_discord_backend](https://hexdocs.pm/logger_discord_backend).



