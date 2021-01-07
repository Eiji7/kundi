defmodule Kundi.HeroSupervisor do
  @moduledoc false

  use DynamicSupervisor

  alias Kundi.Hero

  @impl true
  @spec init(init_arg :: term) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(_init_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

  @spec start_hero(map) :: DynamicSupervisor.on_start_child()
  def start_hero(data) do
    DynamicSupervisor.start_child(__MODULE__, {Hero, data})
  end

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end
end
