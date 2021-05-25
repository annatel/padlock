defmodule Padlock.TestRepo do
  use Ecto.Repo,
    otp_app: :padlock,
    adapter: Ecto.Adapters.MyXQL
end
