defmodule Padlock.TestRepo.Migrations.CreatePadlockTables do
  use Ecto.Migration

  def up do
    Padlock.Migrations.up(from_version: 0, to_version: 1)
  end

  def down do
    Padlock.Migrations.down(from_version: 1, to_version: 0)
  end
end
