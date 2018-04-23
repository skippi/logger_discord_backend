defmodule LoggerDiscordBackend do
  @moduledoc ~S"""
  An elixir `Logger` backend that sends messages to discord.

  # Configuration

  All discord actions must require an authentication token from a Discord App.
  This token is to be placed under nostrum's configuration:

  ```elixir
  config :nostrum,
    token: "discord_auth_token",
    num_shards: 1
  ```

  Additionally, a valid logger configuration must be implemented. First, load
  the backend through Logger's Application Configuration:

  ```elixir
  config :logger,
    backends: [LoggerDiscordBackend],
    level: :debug
  ```

  As a last step, we need to put down a Runtime Configuration for our backend:

  ```elixir
  config :logger, LoggerDiscordBackend,
    level: :error,
    format: "```$date $time [$level] $message```",
    recipient_id: 351500354581692420
  ```

  A final `config.exs` will include an entry similar to this:

  ```elixir
  config :nostrum,
    token: "MzUxOTI4MjE4NDk4MTA1MzQ0.Db22LA.JPO5LgOofR-jjPfJZns_BBJGI-A",
    num_shards: 1

  config :logger,
    backends: [LoggerDiscordBackend],
    level: :debug

  config :logger, LoggerDiscordBackend,
    level: :error,
    format: "```$date $time [$level] $message```",
    recipient_id: 351500354581692420
  ```

  # Configuration Options

  `LoggerDiscordBackend` supports the following configuration options:

    * `:level` - the level to be logged by this backend. Note that messages are
    filtered by the general `:level` configuration for the `:logger` application
    first.

    * `:format` - the format message used to print logs. Defaults to:
    "```$time $metadata[$level] $levelpad$message```". It may also be a
    `{module, function}` tuple that is invoked with the log level, the message,
    the current timestamp and the metadata.

    * `:recipient_id` - the id of the channel to log messages to. Defaults
    to `nil`, which will silently disable this backend from logging messages.
  """

  @behaviour :gen_event

  require Logger

  alias Logger.Formatter
  alias Nostrum.Api
  alias Nostrum.Struct.Snowflake

  import Nostrum.Struct.Snowflake, only: [is_snowflake: 1]

  defstruct [
    :level,
    :recipient_id,
    format: "```$time $metadata[$level] $levelpad$message```"
  ]

  @type config :: %__MODULE__{
          level: Logger.level(),
          format: String.t() | {module, function},
          recipient_id: Snowflake.t()
        }

  def init({__MODULE__, options}) do
    {:ok, configure(options, %__MODULE__{})}
  end

  def init(_) do
    {:ok, configure([], %__MODULE__{})}
  end

  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, state) do
    %{level: log_level} = state

    if meet_level?(level, log_level) do
      {:ok, log_event(level, msg, ts, md, state)}
    else
      {:ok, state}
    end
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event(_, state) do
    {:ok, state}
  end

  def handle_info({:DOWN, ref, _, pid, reason}, %{ref: ref}) do
    raise "device #{inspect(pid)} exited: " <> Exception.format_exit(reason)
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  defp log_event(_level, _msg, _ts, _md, %{recipient_id: nil} = state) do
    {:ok, state}
  end

  defp log_event(level, msg, ts, md, %{recipient_id: recipient_id, format: format} = state)
       when is_snowflake(recipient_id) do
    format_msg = Formatter.format(format, level, msg, ts, md)

    msg = "#{IO.iodata_to_binary(format_msg)}"

    Api.create_message(recipient_id, content: msg)

    state
  end

  defp configure(options, state) do
    config =
      Application.get_env(:logger, __MODULE__, [])
      |> Keyword.merge(options)

    Application.put_env(:logger, __MODULE__, config)

    format = Formatter.compile(Keyword.get(config, :format))
    level = Keyword.get(config, :level)
    recipient_id = Keyword.get(config, :recipient_id)

    %__MODULE__{
      state
      | format: format,
        level: level,
        recipient_id: recipient_id
    }
  end

  defp meet_level?(_lvl, nil), do: true
  defp meet_level?(lvl, min), do: Logger.compare_levels(lvl, min) != :lt
end
