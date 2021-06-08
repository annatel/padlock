defmodule Padlock.SoftLock do
  @doc """
  Generates `:locked_until` and `:lock_version` fields.
  """

  defmacro soft_lock_fields(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      import Ecto.Schema

      timestamps_type = Keyword.get(opts, :timestamps_type, :utc_datetime)

      field(:locked_until, timestamps_type)
      field(:lock_version, :integer, default: 1)
    end
  end

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      import Ecto.Changeset
      import Padlock.SoftLock
      import Ecto.Schema

      @default_lock_retention 30 * 1_000
      @timestamps_type Keyword.get(
                         opts,
                         :timestamps_type,
                         :utc_datetime
                       )

      def default_soft_lock_retention() do
        Application.get_env(:padlock, :default_soft_lock_retention) || @default_lock_retention
      end

      @doc """
      Applies a soft locking to the resource, using optimistic locking to acquire the lock.
      It allows to perform actions while the resource is locked.
      `fun` must be a function receiving the locked resource and returning the resource.
      The return values of `fun` can be {:ok, resource} or {:error, any}.
      """
      @spec with_lock(struct, (struct -> {:ok, struct} | {:error, any}), integer | nil) ::
              {:ok, struct} | {:error, any}
      def with_lock(resource, fun, retention \\ default_soft_lock_retention())
          when is_struct(resource) and is_function(fun, 1) do
        acquire_lock(resource, retention)
        |> case do
          {:ok, resource} when is_struct(resource) -> apply_fun_and_release_lock(fun, resource)
          {:error, "locked"} -> {:error, "locked"}
        end
      end

      defp free?(resource) do
        case resource do
          %{locked_until: nil} ->
            true

          %{locked_until: %DateTime{} = locked_until} ->
            locked_until < utc_now()
        end
      end

      defp apply_fun_and_release_lock(fun, %{__struct__: _} = resource)
           when is_function(fun, 1) do
        case fun.(resource) do
          {:ok, resource} when is_struct(resource) ->
            {:ok, release_lock!(resource)}

          {:error, _} = error ->
            release_lock!(resource)
            error
        end
      end

      defp acquire_lock(resource, retention) do
        if free?(resource) do
          try do
            {:ok,
             resource
             |> lock_changeset(retention)
             |> Padlock.repo().update!()}
          rescue
            Ecto.StaleEntryError ->
              {:error, "locked"}
          end
        else
          {:error, "locked"}
        end
      end

      defp release_lock!(resource) do
        resource
        |> release_changeset()
        |> Padlock.repo().update!()
      end

      defp lock_changeset(resource, retention) when is_integer(retention) do
        resource
        |> change(locked_until: DateTime.add(utc_now(), retention, :millisecond))
        |> optimistic_lock(:lock_version)
      end

      defp release_changeset(resource) do
        resource
        |> change(locked_until: nil)
      end

      def utc_now() do
        case @timestamps_type do
          :utc_datetime -> DateTime.utc_now() |> DateTime.truncate(:second)
          _ -> DateTime.utc_now()
        end
      end
    end
  end
end
