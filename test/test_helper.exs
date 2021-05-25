{:ok, _pid} = Padlock.TestRepo.start_link()
:ok = Ecto.Adapters.SQL.Sandbox.checkout(Padlock.TestRepo)
Ecto.Adapters.SQL.Sandbox.mode(Padlock.TestRepo, {:shared, self()})

ExUnit.start()
