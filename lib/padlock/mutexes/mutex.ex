defmodule Padlock.Mutexes.Mutex do
  use Ecto.Schema

  import Ecto.Changeset, only: [cast: 3, unique_constraint: 2, validate_required: 2]

  @type t :: %__MODULE__{id: binary, name: binary}

  @primary_key {:id, :id, autogenerate: true}
  schema "padlock_mutexes" do
    field(:name, :string)
  end

  @doc false
  @spec changeset(Event.t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = event, attrs) do
    event
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
