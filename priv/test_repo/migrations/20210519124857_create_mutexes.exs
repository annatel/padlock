defmodule Padlock.TestRepo.Migrations.CreateMutexes do
  use Ecto.Migration

  def up do
    Padlock.Mutexes.Migrations.V1.up()
  end

  def down do
    Padlock.Mutexes.Migrations.V1.down()
  end
end
