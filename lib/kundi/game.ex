defmodule Kundi.Game do
  @moduledoc """
  Defines a Game struct and GenServer
  """

  use GenServer

  alias Kundi.{GameRegistry, Grid, Hero}

  defstruct [:heros, :name, grid: Grid.generate()]

  @typedoc "An init parameters required when starting game's GenServer"
  @type init_params :: %{required(:hero) => Hero.name(), required(:name) => name}

  @typedoc "A game name"
  @type name :: String.t()

  @typedoc "Heros grouped by position on the grid"
  @type opponents :: %{optional(Hero.point()) => list(Hero.t())}

  @typedoc "A game struct"
  @type t :: %__MODULE__{grid: Grid.t(), heros: list(Hero.name()), name: name}

  @doc """
  Adds a hero name to game's heros list
  """
  @spec add_hero(name, Hero.name()) :: :ok
  def add_hero(name, hero_name), do: cast(name, {:add_hero, hero_name})

  @doc """
  Gets a game by its name
  """
  @spec get_game(name) :: t()
  def get_game(name), do: call(name, :get_game)

  @doc """
  Gets a game opponents from game or fetching it from its name.
  Opponents are grouped by their position on the grid.
  """
  @spec get_opponents(t() | name, Hero.name()) :: opponents()
  def get_opponents(%__MODULE__{heros: heros}, current_name) do
    Enum.reduce(heros, %{}, fn
      ^current_name, acc ->
        acc

      name, acc ->
        %{point: point} = hero = Hero.get_hero(name)
        Map.update(acc, point, [hero], &[hero | &1])
    end)
  end

  def get_opponents(name, hero_name), do: name |> get_game() |> get_opponents(hero_name)

  @doc """
  Gets a random empty/walkable position on grid.
  """
  @spec get_random_point(name) :: Hero.point()
  def get_random_point(name) do
    name |> get_game() |> Map.fetch!(:grid) |> Grid.get_random_point()
  end

  @doc """
  Starts a game GenServer
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
  def init(data), do: {:ok, %__MODULE__{heros: [data.hero], name: data.name}}

  @doc false
  @impl true
  @spec handle_call(:get_game, GenServer.from(), t()) :: {:reply, t(), t()}
  def handle_call(:get_game, _from, game), do: {:reply, game, game}

  @doc false
  @impl true
  @spec handle_cast({:add_hero, Hero.name()}, t()) :: {:noreply, t()}
  def handle_cast({:add_hero, hero}, %{heros: heros} = game) do
    if hero in heros do
      {:noreply, game}
    else
      {:noreply, %{game | heros: [hero | heros]}}
    end
  end

  @spec process_name(name) :: {:via, Registry, {GameRegistry, name}}
  defp process_name(name), do: {:via, Registry, {GameRegistry, name}}
end
