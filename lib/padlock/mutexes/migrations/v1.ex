defmodule Padlock.Mutexes.Migrations.V1 do
  @moduledoc false

  use Ecto.Migration

  def up do
    create_mutexes_table()
  end

  def down do
    drop_mutexes_table()
  end

  defp create_mutexes_table() do
    create table(:padlock_mutexes) do
      add(:name, :string, null: false)
    end

    create(unique_index(:padlock_mutexes, [:name]))
  end

  defp drop_mutexes_table do
    drop(table(:padlock_mutexes))
  end
end
