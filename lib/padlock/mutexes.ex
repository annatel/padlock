defmodule Padlock.Mutexes do
  import Ecto.Query, only: [lock: 2]

  alias Ecto.Multi

  alias Padlock.Mutexes.Mutex

  @spec lock!(binary) :: Mutex.t()
  def lock!(name) when is_binary(name) do
    Multi.new()
    |> Multi.put(:current_mutex, get_mutex_by(name: name))
    |> Multi.run(:mutex, fn
      _, %{current_mutex: %Mutex{} = mutex} ->
        {:ok, mutex}

      _, %{current_mutex: nil} ->
        _ = create_mutex(name)

        {:ok, get_mutex_by(name: name)}
    end)
    |> Padlock.repo().transaction()
    |> case do
      {:ok, %{mutex: mutex}} -> mutex
    end
  end

  defp get_mutex_by(name: name) when is_binary(name),
    do: Mutex |> lock("FOR UPDATE") |> Padlock.repo().get_by(name: name)

  defp create_mutex(name) when is_binary(name) do
    %Mutex{}
    |> Mutex.changeset(%{name: name})
    |> Padlock.repo().insert()
  end
end
