defmodule Kundi.Support.Helper do
  @moduledoc false

  alias Kundi.Grid

  require Grid

  def find_geralt(grid, start, target) do
    Agent.start_link(fn -> [] end, name: :visited_points)
    result = find_geralt(grid, start, target, [])
    Agent.update(:visited_points, fn _ -> [] end)
    result
  end

  defp find_geralt(grid, current, target, path) do
    Agent.update(:visited_points, &[current | &1])

    if current == target do
      Enum.reverse(path)
    else
      grid
      |> get_neighbours(current)
      |> Enum.map(&find_geralt(grid, &1, target, [&1 | path]))
      |> deep_shortest()
    end
  end

  defp deep_shortest([]), do: []

  defp deep_shortest([{_, _} | _tail] = list), do: list

  defp deep_shortest(list) do
    if Enum.any?(list, &path?/1) do
      list |> Enum.map(&deep_shortest/1) |> Enum.reject(&(&1 == [])) |> Enum.min_by(&Enum.count/1)
    else
      list |> Enum.concat() |> deep_shortest()
    end
  end

  defp path?([{_, _} | _tail]), do: true
  defp path?(_list), do: false

  def get_assigns(params) do
    params
    |> Kundi.join_game()
    |> Kundi.handle_event(params)
    |> Kundi.get_opponents()
  end

  def get_neighbours(grid, {x, y}) do
    list = Enum.filter([{x - 1, y}, {x, y - 1}, {x + 1, y}, {x, y + 1}], &walkable?(grid, &1))
    pid = Process.whereis(:visited_points)

    if is_nil(pid) do
      list
    else
      Enum.reject(list, &visited?/1)
    end
  end

  defp walkable?(grid, point), do: grid |> Grid.get_cell(point) |> Grid.is_empty()

  defp visited?(point), do: Agent.get(:visited_points, &(point in &1))

  def move_to(assigns, []), do: assigns

  def move_to(assigns, [head | tail]) do
    hero = assigns[:hero]

    %{
      "game" => assigns[:game].name,
      "hero" => hero.name,
      "event" => "move",
      "direction" => get_direction(hero.point, head)
    }
    |> get_assigns()
    |> move_to(tail)
  end

  defp get_direction({x, y1}, {x, y2}) when y1 < y2, do: "down"
  defp get_direction({x1, y}, {x2, y}) when x1 > x2, do: "left"
  defp get_direction({x1, y}, {x2, y}) when x1 < x2, do: "right"
  defp get_direction({x, y1}, {x, y2}) when y1 > y2, do: "up"

  def simulate_page_refresh, do: Process.sleep(1000)
end
