defmodule Padlock.TestSoftLockResource do
  use Ecto.Schema
  use Padlock.SoftLock

  schema "test_soft_lock_resources" do
    soft_lock_fields()
  end
end

defmodule Padlock.SoftLockTest do
  use ExUnit.Case
  use Padlock.DataCase

  alias Padlock.TestSoftLockResource

  describe "with_lock/2" do
    test "can lock the resource if it has not any locks, default retention" do
      resource = %TestSoftLockResource{locked_until: nil} |> Padlock.repo().insert!()

      {:ok, %{locked_until: nil}} =
        TestSoftLockResource.with_lock(resource, fn resource ->
          assert %{locked_until: %DateTime{} = locked_until, lock_version: 2} = resource

          assert_in_delta DateTime.to_unix(locked_until),
                          DateTime.to_unix(
                            DateTime.add(DateTime.utc_now(), 30 * 1_000, :millisecond)
                          ),
                          1

          {:ok, resource}
        end)
    end

    test "can't lock the resource if it has an active lock" do
      in_two_minutes =
        DateTime.utc_now() |> DateTime.add(2 * 60, :second) |> DateTime.truncate(:second)

      resource = %TestSoftLockResource{locked_until: in_two_minutes} |> Padlock.repo().insert!()

      assert {:error, "locked"} = TestSoftLockResource.with_lock(resource, &{:ok, &1})
    end

    test "can lock the resource although a lock exists if the lock is expired" do
      two_minutes_ago =
        DateTime.utc_now() |> DateTime.add(-2 * 60, :second) |> DateTime.truncate(:second)

      resource = %TestSoftLockResource{locked_until: two_minutes_ago} |> Padlock.repo().insert!()

      assert {:ok, _} = TestSoftLockResource.with_lock(resource, &{:ok, &1})
    end

    test "when the function returns an error" do
      resource = %TestSoftLockResource{locked_until: nil} |> Padlock.repo().insert!()

      assert {:error, "error"} =
               TestSoftLockResource.with_lock(resource, fn _ -> {:error, "error"} end)
    end

    test "race condition" do
      resource = %TestSoftLockResource{locked_until: nil} |> Padlock.repo().insert!()

      TestSoftLockResource.with_lock(resource, &{:ok, &1})
      assert {:error, "locked"} = TestSoftLockResource.with_lock(resource, &{:ok, &1})
    end

    test "retention in config" do
      retention = 10 * 1_000
      Application.put_env(:padlock, :default_soft_lock_retention, retention)
      on_exit(fn -> Application.delete_env(:padlock, :default_soft_lock_retention) end)

      resource = %TestSoftLockResource{locked_until: nil} |> Padlock.repo().insert!()

      assert {:ok, _} =
               TestSoftLockResource.with_lock(resource, fn resource ->
                 assert_in_delta DateTime.to_unix(resource.locked_until),
                                 DateTime.to_unix(
                                   DateTime.add(DateTime.utc_now(), retention, :millisecond)
                                 ),
                                 1

                 {:ok, resource}
               end)
    end

    test "retention in params" do
      Application.put_env(:padlock, :default_soft_lock_retention, 10 * 1_000)
      on_exit(fn -> Application.delete_env(:padlock, :default_soft_lock_retention) end)

      resource = %TestSoftLockResource{locked_until: nil} |> Padlock.repo().insert!()

      retention = 20 * 1_000

      assert {:ok, _} =
               TestSoftLockResource.with_lock(
                 resource,
                 fn resource ->
                   assert_in_delta DateTime.to_unix(resource.locked_until),
                                   DateTime.to_unix(
                                     DateTime.add(DateTime.utc_now(), retention, :millisecond)
                                   ),
                                   1

                   {:ok, resource}
                 end,
                 retention
               )
    end
  end
end
