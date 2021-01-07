defmodule Kundi do
  @moduledoc """
  Defines reusable functions used in router and tests.
  """

  alias Kundi.{Game, GameRegistry, GameSupervisor, Hero, HeroRegistry, HeroSupervisor}
  alias Plug.Conn

  @typep game_hero_map :: %{
           required(:game | :hero) => Game.name() | Hero.name(),
           name: Game.name() | Hero.name()
         }

  @doc """
  Adds opponents to keyword for specified game and hero names
  """
  @spec get_opponents(list({:game, Game.t()} | {:hero, Hero.t()})) ::
          list({:game, Game.t()} | {:hero, Hero.t()} | {:opponents, Game.opponents()})
  def get_opponents(game: game, hero: hero) do
    [game: game, hero: hero, opponents: Game.get_opponents(game.name, hero.name)]
  end

  @doc """
  Handles game events like hero attack or move

  Params is a map with string keys and values:
  * event - an event name - one of: attack, move
  * direction - if event is set to move accept one of 4 directions: down, left, right or up
  """
  @spec handle_event(data, params :: Conn.params()) :: data
        when data: list({:game, Game.t()} | {:hero, Hero.t()})
  def handle_event([game: game, hero: hero], %{"event" => "attack"}) do
    Hero.attack(hero.name)
    [game: game, hero: hero]
  end

  def handle_event([game: game, hero: hero], %{"direction" => direction, "event" => "move"}) do
    Hero.move(hero.name, direction)
    [game: game, hero: get(%{game: game.name, name: hero.name}, :hero)]
  end

  def handle_event([game: game, hero: hero], _params) do
    [game: game, hero: hero]
  end

  @doc """
  Join hero to a game. If game or hero does not exists they would be created and registered.

  Params is a map with string keys and values:
  * game - a game name
  * hero - a hero name
  """
  @spec join_game(params :: Conn.params()) :: list({:game, Game.t()} | {:hero, Hero.t()})
  def join_game(%{"game" => game_name, "hero" => hero_name}) do
    game = get(%{hero: hero_name, name: game_name}, :game)
    hero = get(%{game: game_name, name: hero_name}, :hero)
    [game: game, hero: hero]
  end

  @spec get(game_hero_map, :game | :hero) :: Game.t() | Hero.t()
  defp get(%{name: name} = data, type) do
    case lookup(name, type) do
      [] -> start(data, type)
      [{_pid, nil}] -> join(data, type)
    end
  end

  @spec lookup(Game.name() | Hero.name(), :game | :hero) :: [] | list({pid, nil})
  defp lookup(name, :game), do: Registry.lookup(GameRegistry, name)
  defp lookup(name, :hero), do: Registry.lookup(HeroRegistry, name)

  @spec join(game_hero_map, :game | :hero) :: Game.t() | Hero.t()
  defp join(data, :game) do
    Game.add_hero(data.name, data.hero)
    Game.get_game(data.name)
  end

  defp join(data, :hero) do
    Hero.get_hero(data.name)
  end

  @spec start(game_hero_map, :game | :hero) :: Game.t() | Hero.t()
  defp start(data, :game) do
    GameSupervisor.start_game(data)
    Game.get_game(data.name)
  end

  defp start(data, :hero) do
    HeroSupervisor.start_hero(data)
    Hero.get_hero(data.name)
  end
end
