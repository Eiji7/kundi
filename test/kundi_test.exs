defmodule KundiTest do
  use ExUnit.Case

  alias Kundi.Hero
  alias Kundi.Support.Helper

  doctest Kundi.Grid

  test "events" do
    heros_are_distinguishable()
    go_to_geralt()
    kill_geralt()
    geralt_cant_move()
    geralt_cant_attack()
    geralt_respawn()
  end

  defp heros_are_distinguishable do
    geralt_assigns = Helper.get_assigns(%{"game" => "withcher", "hero" => "geralt"})
    yennefer_assigns = Helper.get_assigns(%{"game" => "withcher", "hero" => "yennefer"})
    geralt_hero = geralt_assigns[:hero]
    yennefer_hero = yennefer_assigns[:hero]
    assert geralt_assigns[:opponents] == %{}
    assert yennefer_assigns[:opponents] == %{geralt_hero.point => [geralt_hero]}
    geralt_assigns = Helper.get_assigns(%{"game" => "withcher", "hero" => "geralt"})
    assert geralt_assigns[:opponents] == %{yennefer_hero.point => [yennefer_hero]}
    assert yennefer_assigns == Helper.get_assigns(%{"game" => "withcher", "hero" => "yennefer"})
  end

  defp go_to_geralt do
    geralt_assigns = Helper.get_assigns(%{"game" => "withcher", "hero" => "geralt"})
    yennefer_assigns = Helper.get_assigns(%{"game" => "withcher", "hero" => "yennefer"})
    grid = yennefer_assigns[:game].grid
    start = yennefer_assigns[:hero].point
    target = geralt_assigns[:hero].point
    path = Helper.find_geralt(grid, start, target)
    assert Helper.move_to(yennefer_assigns, path)[:hero].point == target
  end

  defp kill_geralt do
    Helper.get_assigns(%{"game" => "withcher", "hero" => "yennefer", "event" => "attack"})
    Helper.simulate_page_refresh()
    dead_geralt_assigns = Helper.get_assigns(%{"game" => "withcher", "hero" => "geralt"})
    yennefer_assigns = Helper.get_assigns(%{"game" => "withcher", "hero" => "yennefer"})
    assert %Hero{alive: false} = dead_geralt_assigns[:hero]
    dead_geralt = dead_geralt_assigns[:hero]
    assert [^dead_geralt] = yennefer_assigns[:opponents][dead_geralt.point]
  end

  defp geralt_cant_move do
    dead_geralt_assigns = Helper.get_assigns(%{"game" => "withcher", "hero" => "geralt"})
    grid = dead_geralt_assigns[:game].grid
    start = dead_geralt_assigns[:hero].point
    [target | _rest] = Helper.get_neighbours(grid, start)
    assigns = Helper.move_to(dead_geralt_assigns, [target])
    assert assigns[:hero].point == start
  end

  defp geralt_cant_attack do
    Helper.get_assigns(%{"game" => "withcher", "hero" => "geralt", "event" => "attack"})
    assigns = Helper.get_assigns(%{"game" => "withcher", "hero" => "yennefer"})
    assert %Hero{alive: true} = assigns[:hero]
  end

  defp geralt_respawn do
    for _x <- 1..5, do: Helper.simulate_page_refresh()
    assigns = Helper.get_assigns(%{"game" => "withcher", "hero" => "geralt"})
    assert %Hero{alive: true} = assigns[:hero]
  end
end
