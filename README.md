# Padlock

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/annatel/padlock/main?cacheSeconds=3600&style=flat-square)](https://github.com/annatel/padlock/actions) [![GitHub issues](https://img.shields.io/github/issues-raw/annatel/padlock?style=flat-square&cacheSeconds=3600)](https://github.com/annatel/padlock/issues) [![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?cacheSeconds=3600?style=flat-square)](http://opensource.org/licenses/MIT) [![Hex.pm](https://img.shields.io/hexpm/v/padlock?style=flat-square)](https://hex.pm/packages/padlock) [![Hex.pm](https://img.shields.io/hexpm/dt/padlock?style=flat-square)](https://hex.pm/packages/padlock)

Create a mutex

## Installation

Padlock is published on [Hex](https://hex.pm/packages/padlock).  
The package can be installed by adding `padlock` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:padlock, "~> 0.1.1"}
  ]
end
```

After the packages are installed you must create a database migration for each version to add the padlock tables to your database.

For mutexes:

```elixir
defmodule Padlock.TestRepo.Migrations.CreatePadlockTables do
  use Ecto.Migration

  def up do
    Padlock.Mutexes.Migrations.V1.up()
  end

  def down do
    Padlock.Mutexes.Migrations.V1.down()
  end
end

```

For soft_lock:

```elixir
defmodule Padlock.TestRepo.Migrations.CreatePadlockTables do
  use Ecto.Migration

  def up do
    Padlock.SoftLock.Migration.up()
  end

  def down do
    Padlock.SoftLock.Migration.down()
  end
end

```

This will run all of Padlock's versioned migrations for your database. Migrations between versions are idempotent and will never change after a release. As new versions are released you may need to run additional migrations.

Now, run the migration to create the table:

```sh
mix ecto.migrate
```