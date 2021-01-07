defmodule Kundi.Grid do
  @moduledoc """
  Simple grid helper module.
  """

  alias Kundi.Hero

  @typedoc """
  Represent tile type:

  * 0 - walkable/empty tile
  * 1 - wall
  """
  @type cell :: 1 | 0

  @typedoc """
  A grid row is simply a list of cells.
  """
  @type row :: list(cell)

  @typedoc """
  Our grid is simply a list of rows.
  """
  @type t :: list(row)

  @kundi """
  0000000000000000000000000
  0101010010110010111001110
  0110010010101010100100100
  0101001100100110110001110
  0000000000000000000000000
  """

  @doc """
  A helper guard which determines if cell is empty.

  ## Examples

      iex> #{to_string(__MODULE__)}.is_empty(0)
      true
      iex> #{to_string(__MODULE__)}.is_empty(1)
      false
  """
  defguard is_empty(cell) when cell == 0

  @doc """
  A helper guard which determines if cell is wall.

  ## Examples

      iex> #{to_string(__MODULE__)}.is_wall(1)
      true
      iex> #{to_string(__MODULE__)}.is_wall(0)
      false
  """
  defguard is_wall(cell) when cell == 1

  @doc """
  An example generated grid.
  For simplicity and readability we convert a predefined string to grid.
  """
  @spec generate :: t()
  def generate, do: to_grid(@kundi)

  @doc """
  Retrieves a cell from grid.

  ## Examples

      iex> grid = [[1, 0, 1], [0, 1, 0]]
      iex> #{to_string(__MODULE__)}.get_cell(grid, {1, 1})
      1
      iex> #{to_string(__MODULE__)}.get_cell(grid, {3, 2})
      0
  """
  @spec get_cell(t(), Hero.point()) :: cell | nil
  def get_cell(_grid, {x, y}) when x < 1 or y < 1, do: nil

  def get_cell(grid, {x, y}) do
    row = Enum.at(grid, y - 1)
    if is_list(row), do: Enum.at(row, x - 1)
  end

  @doc """
  Gets a random empty/walkable position on grid.

  ## Examples

      iex> grid = [[1, 0, 1]]
      iex> #{to_string(__MODULE__)}.get_random_point(grid)
      {2, 1}
  """
  @spec get_random_point(t()) :: Hero.point()
  def get_random_point([row | _tail] = grid) do
    cells_range = 1..Enum.count(row)
    rows_range = 1..Enum.count(grid)
    point = {Enum.random(cells_range), Enum.random(rows_range)}
    cell = get_cell(grid, point)

    if is_wall(cell) do
      get_random_point(grid)
    else
      point
    end
  end

  @doc ~s'''
  Parses string to grid.

  ## Examples

      iex> string = """
      ...> 101
      ...> 010
      ...> """
      iex> #{to_string(__MODULE__)}.to_grid(string)
      [[1, 0, 1], [0, 1, 0]]
  '''
  @spec to_grid(String.t(), t()) :: t()
  def to_grid(string, acc \\ [[]])
  def to_grid("1" <> rest, [current | acc]), do: to_grid(rest, [[1 | current] | acc])
  def to_grid("0" <> rest, [current | acc]), do: to_grid(rest, [[0 | current] | acc])
  def to_grid("\n", [current | acc]), do: Enum.reverse([Enum.reverse(current) | acc])
  def to_grid("\n" <> rest, [current | acc]), do: to_grid(rest, [[], Enum.reverse(current) | acc])
end
