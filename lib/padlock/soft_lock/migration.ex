defmodule Padlock.SoftLock.Migration do
  defmacro __using__(_) do
    quote location: :keep do
      import Ecto.Migration

      @doc """
      Adds `:locked_until` and `:lock_version` timestamp columns.
      """
      def soft_lock_fields(opts \\ []) do
        locked_until_timestamp_type =
          Keyword.get(opts, :locked_until_timestamp_type, :utc_datetime)

        add(:locked_until, locked_until_timestamp_type, null: true)
        add(:lock_version, :integer, null: false, default: 1)
      end
    end
  end
end
