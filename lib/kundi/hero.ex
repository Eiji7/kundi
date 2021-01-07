defmodule Kundi.Hero do
  @moduledoc """
  Defines a Hero struct and GenServer
  """

  use GenServer

  alias Kundi.{Game, Grid, HeroRegistry}

  require Grid

  defstruct [:game, :name, :point, alive: true]

  @typedoc "A movement direction. Possible values: down, left, right, up"
  @type direction :: String.t()

  @typedoc "An init parameters required when starting hero's GenServer"
  @type init_params :: %{required(:game) => Game.name(), required(:name) => name}

  @typedoc "A hero name"
  @type name :: String.t()

  @typedoc "Position of hero on the grid"
  @type point :: {x :: pos_integer(), y :: pos_integer()}

  @typedoc "A hero struct"
  @type t :: %__MODULE__{alive: boolean, game: Game.name(), name: name, point: point}

  @doc """
  Attacks everyone else within the radius of 1 tile around hero
  (in all directions) + the tile hero is standing on.
  """
  @spec attack(name) :: :ok
  def attack(name), do: cast(name, :attack)

  @doc """
  Gets a hero by its name
  """
  @spec get_hero(name) :: t()
  def get_hero(name), do: call(name, :get_hero)

  @doc """
  Moves a hero on the grid if possible
  """
  @spec move(name, direction) :: :ok
  def move(name, direction), do: cast(name, {:move, direction})

  @doc """
  Respawns hero
  """
  @spec respawn(name) :: :ok
  def respawn(name), do: cast(name, :respawn)

  @doc """
  Starts a hero GenServer
  """
  @spec start_link(init_params) :: GenServer.on_start()
  def start_link(data), do: GenServer.start_link(__MODULE__, data, name: process_name(data.name))

  @spec call(name, request :: term) :: response :: term
  defp call(name, request), do: name |> process_name() |> GenServer.call(request)

  @spec cast(name, request :: term) :: :ok
  defp cast(name, request), do: name |> process_name() |> GenServer.cast(request)

  @doc false
  @impl true
  @spec init(init_params) :: {:ok, t()}
  def init(data) do
    {:ok, %__MODULE__{game: data.game, name: data.name, point: Game.get_random_point(data.game)}}
  end

  @doc false
  @impl true
  @spec handle_call(:get_hero, GenServer.from(), t()) :: {:reply, t(), t()}
  def handle_call(:get_hero, _from, hero), do: {:reply, hero, hero}

  @doc false
  @impl true
  @spec handle_cast(:attack, t()) :: {:noreply, t()}
  def handle_cast(:attack, %{alive: false} = hero), do: {:noreply, hero}

  def handle_cast(:attack, %{game: game_name, point: {x, y}} = hero) do
    %{grid: grid} = game = Game.get_game(game_name)
    opponents = Game.get_opponents(game, hero.name)
    range = for ydiff <- -1..1, xdiff <- -1..1, do: {x + xdiff, y + ydiff}
    Enum.each(range, &attack(grid, &1, opponents))
    {:noreply, hero}
  end

  @impl true
  @spec handle_cast(:killed, t()) :: {:noreply, t()}
  def handle_cast(:killed, hero) do
    Task.start(fn ->
      Process.sleep(5000)
      respawn(hero.name)
    end)

    {:noreply, %{hero | alive: false}}
  end

  @impl true
  @spec handle_cast({:move, direction}, t()) :: {:noreply, t()}
  def handle_cast({:move, _}, %{alive: false} = hero), do: {:noreply, hero}
  def handle_cast({:move, "down"}, %{point: {x, y}} = hero), do: move_to(hero, {x, y + 1})
  def handle_cast({:move, "left"}, %{point: {x, y}} = hero), do: move_to(hero, {x - 1, y})
  def handle_cast({:move, "right"}, %{point: {x, y}} = hero), do: move_to(hero, {x + 1, y})
  def handle_cast({:move, "up"}, %{point: {x, y}} = hero), do: move_to(hero, {x, y - 1})

  @spec handle_cast(:respawn, t()) :: {:noreply, t()}
  def handle_cast(:respawn, hero) do
    {:noreply, %{hero | alive: true, point: Game.get_random_point(hero.game)}}
  end

  @spec attack(Grid.t(), point(), Game.opponents()) :: nil | list(:ok)
  defp attack(grid, point, opponents) do
    cell = Grid.get_cell(grid, point)

    if Grid.is_empty(cell) do
      Enum.map(opponents[point] || [], &kill/1)
    end
  end

  @spec kill(t()) :: :ok
  defp kill(%{alive: false}), do: :ok
  defp kill(hero), do: hero.name |> process_name() |> GenServer.cast(:killed)

  @spec move_to(t(), point()) :: {:noreply, t()}
  defp move_to(%{game: game_name} = hero, new_point) do
    %{grid: grid} = Game.get_game(game_name)
    cell = Grid.get_cell(grid, new_point)

    if Grid.is_empty(cell) do
      {:noreply, %{hero | point: new_point}}
    else
      {:noreply, hero}
    end
  end

  @spec process_name(name) :: {:via, Registry, {HeroRegistry, name}}
  defp process_name(name), do: {:via, Registry, {HeroRegistry, name}}
end
