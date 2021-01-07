defmodule Kundi.HeroTest do
  use ExUnit.Case

  alias Kundi.{GameSupervisor, Hero, HeroSupervisor}

  test "needs a game to start" do
    count = DynamicSupervisor.count_children(HeroSupervisor)
    HeroSupervisor.start_hero(%{game: "witcher3", name: "geralt3"})
    assert count == DynamicSupervisor.count_children(HeroSupervisor)
    GameSupervisor.start_game(%{hero: "geralt3", name: "witcher3"})
    HeroSupervisor.start_hero(%{game: "witcher3", name: "geralt3"})
    assert count < DynamicSupervisor.count_children(HeroSupervisor)
    assert %Hero{alive: true, game: "witcher3", name: "geralt3"} = Hero.get_hero("geralt3")
  end
end
