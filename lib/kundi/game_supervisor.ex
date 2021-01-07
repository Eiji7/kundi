defmodule Kundi.GameSupervisor do
  @moduledoc false

  use DynamicSupervisor

  alias Kundi.Game

  @impl true
  @spec init(init_arg :: term) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(_init_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

  @spec start_game(map) :: DynamicSupervisor.on_start_child()
  def start_game(data) do
    DynamicSupervisor.start_child(__MODULE__, {Game, data})
  end

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end
end
