import Config

if(Mix.env() == :test) do
  config :logger, level: System.get_env("EX_LOG_LEVEL", "warn") |> String.to_atom()

  config :padlock, ecto_repos: [Padlock.TestRepo]

  config :padlock, Padlock.TestRepo,
    url: System.get_env("PADLOCK__DATABASE_TEST_URL"),
    show_sensitive_data_on_connection_error: true,
    pool: Ecto.Adapters.SQL.Sandbox

  config :padlock,
    repo: Padlock.TestRepo
end
