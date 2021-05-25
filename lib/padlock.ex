defmodule Padlock do
  @moduledoc """
  Documentation for `Padlock`.
  """

  alias Padlock.Mutexes

  @spec lock!(binary) :: Mutex.t()
  defdelegate lock!(name), to: Mutexes

  @doc false
  @spec repo :: module
  def repo() do
    Application.fetch_env!(:padlock, :repo)
  end
end
