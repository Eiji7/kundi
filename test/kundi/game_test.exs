defmodule Kundi.GameTest do
  use ExUnit.Case

  alias Kundi.{Game, GameSupervisor, Grid, HeroSupervisor}

  test "can start without hero avoiding init circulat dependency" do
    count = DynamicSupervisor.count_children(GameSupervisor)
    hero_count = DynamicSupervisor.count_children(HeroSupervisor)
    GameSupervisor.start_game(%{hero: "geralt2", name: "witcher2"})
    assert count < DynamicSupervisor.count_children(GameSupervisor)
    assert hero_count == DynamicSupervisor.count_children(HeroSupervisor)
    game = Game.get_game("witcher2")
    assert %Game{heros: ["geralt2"], name: "witcher2"} = game
    assert game.grid == Grid.generate()
  end
end
