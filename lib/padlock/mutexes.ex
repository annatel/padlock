defmodule Padlock.Mutexes do
  import Ecto.Query, only: [lock: 2]

  alias Padlock.Mutexes.Mutex

  @spec lock!(binary) :: Mutex.t()
  def lock!(name) when is_binary(name) do
    {:ok, mutex} =
      Padlock.repo().transaction(fn ->
        create_if_not_exist_mutex!(name)
        acquire_mutex!(name)
      end)

    mutex
  end

  defp acquire_mutex!(name) when is_binary(name),
    do: Mutex |> lock("FOR UPDATE") |> Padlock.repo().get_by!(name: name)

  defp create_if_not_exist_mutex!(name) when is_binary(name) do
    %Mutex{}
    |> Mutex.changeset(%{name: name})
    |> Padlock.repo().insert!(on_conflict: :nothing)
  end
end
