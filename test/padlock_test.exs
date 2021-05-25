defmodule PadlockTest do
  use ExUnit.Case
  use Padlock.DataCase

  alias Padlock.TestRepo

  alias Padlock.Mutexes.Mutex

  test "lock when the mutex does not exists, creates the mutex and lock it" do
    owner = self()

    Task.async(fn ->
      Ecto.Adapters.SQL.Sandbox.allow(TestRepo, owner, self())

      send(owner, :before_lock_1)

      TestRepo.transaction(fn ->
        assert %Mutex{name: "name"} = Padlock.lock!("name")
        :timer.sleep(500)
      end)

      send(owner, :after_lock_1)
    end)

    Task.async(fn ->
      Ecto.Adapters.SQL.Sandbox.allow(TestRepo, owner, self())

      send(owner, :before_lock_2)
      assert %Mutex{name: "name"} = Padlock.lock!("name")
      send(owner, :after_lock_2)
    end)

    assert_receive :before_lock_1
    assert_receive :before_lock_2

    refute_receive :after_lock_2, 500
    assert_receive :after_lock_1
    assert_receive :after_lock_2
  end
end
