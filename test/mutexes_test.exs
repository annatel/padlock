defmodule Padlock.MutexesTest do
  use ExUnit.Case
  use Padlock.DataCase

  alias Padlock.TestRepo
  alias Padlock.Mutexes.Mutex

  defmacro assert_next_receive(pattern, timeout \\ 100) do
    quote do
      receive do
        message ->
          assert unquote(pattern) = message
      after
        unquote(timeout) ->
          raise "timeout"
      end
    end
  end

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(TestRepo, {:shared, self()})
    :ok
  end

  test "when the mutex exists" do
    %Mutex{name: "name"} |> TestRepo.insert!()

    assert %Mutex{name: "name"} = Padlock.lock!("name")
  end

  test "when the mutex does not exist" do
    assert %Mutex{name: "name"} = Padlock.lock!("name")
  end

  test "if the resource is locked, wait" do
    owner = self()

    TestRepo.transaction(fn ->
      send(owner, :before_lock_1)

      Padlock.lock!("name")

      Process.spawn(
        fn ->
          send(owner, :before_lock_2)

          Padlock.lock!("name")

          send(owner, :after_lock_2)
        end,
        [:monitor]
      )

      :timer.sleep(500)

      send(owner, :after_lock_1)
    end)

    assert_next_receive(:before_lock_1)
    assert_next_receive(:before_lock_2)
    assert_next_receive(:after_lock_1)
    assert_next_receive(:after_lock_2)
  end
end
