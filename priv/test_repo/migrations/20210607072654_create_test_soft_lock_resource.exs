defmodule Padlock.TestRepo.Migrations.CreateTestSoftLockResources do
  use Ecto.Migration
  use Padlock.SoftLock.Migration

  def change do
    create table(:test_soft_lock_resources) do
      soft_lock_fields(timestamps_type: :utc_datetime)
    end
  end
end
