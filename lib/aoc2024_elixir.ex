defmodule Aoc2024Elixir.Day1 do
  def testinput do
    """
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
    """
  end

  @spec part1(binary()) :: integer()
  def part1(input) do
    _parse_input(input)
    |> Stream.map(&Enum.sort/1)
    |> Stream.zip()
    |> Stream.map(fn p ->
      {a, b} = p
      abs(a - b)
    end)
    |> Enum.reduce(0, &(&1 + &2))
  end

  @spec part2(binary()) :: integer()
  def part2(input) do
    [list_a, list_b] = _parse_input(input) |> Enum.to_list()
    list_b_counts = Enum.frequencies(list_b)

    Enum.reduce(list_a, 0, fn i, acc ->
      acc + i * Map.get(list_b_counts, i, 0)
    end)
  end

  defp _parse_input(input) do
    String.trim(input)
    |> String.split("\n")
    |> Stream.flat_map(&String.split(&1, "   "))
    |> Stream.map(&String.to_integer/1)
    |> Stream.chunk_every(2)
    |> Stream.zip()
    |> Stream.map(&Tuple.to_list/1)
  end
end

defmodule Aoc2024Elixir.Day2 do
  def testinput() do
    """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    4 7 8 9 9
    2 5 6 8 6
    """
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(input) do
    _parse_input(input)
    |> Stream.map(fn line ->
      _test_line(line, 1)
    end)
    |> Enum.count(& &1)
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(input) do
    _parse_input(input)
    |> Stream.map(fn line ->
      _test_line(line, 0)
    end)
    |> Enum.count(& &1)
  end

  defp _test_line(line, correction) do
    line_valid = _test_line_impl(line)

    if not line_valid and correction < 1 do
      _possible_corrections(line)
      |> Enum.any?(fn corrected_line ->
        _test_line(corrected_line, 1)
      end)
    else
      line_valid
    end
  end

  defp _test_line_impl(line) do
    direction = _line_direction(line)

    if direction == :zero do
      false
    else
      _pairwise(line)
      |> Enum.all?(fn pair ->
        _test_pair(pair, direction)
      end)
    end
  end

  defp _line_direction(line) do
    [a, b] = Enum.take(line, 2)

    cond do
      a < b -> :increasing
      b < a -> :decreasing
      true -> :zero
    end
  end

  defp _test_pair(pair, direction) do
    {a, b} = pair
    d = a - b

    if d == 0 do
      false
    end

    case direction do
      :increasing -> -4 < d and d < 0
      :decreasing -> 0 < d and d < 4
    end
  end

  defp _parse_input(input) do
    String.trim(input)
    |> String.split("\n")
    |> Stream.map(fn line ->
      String.split(line, " ")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp _pairwise(list) do
    Stream.zip(list, Stream.take(list, -length(list) + 1))
  end

  defp _possible_corrections(list) do
    Stream.map(0..length(list), fn i ->
      {_, corrected_list} = List.pop_at(list, i)
      corrected_list
    end)
  end
end

defmodule Aoc2024Elixir.Day3 do
  def testdata do
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"
  end

  def testdata2 do
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"
  end

  def part1(input) do
    Regex.scan(~r"mul\((\d+),(\d+)\)", input)
    |> Stream.map(fn match ->
      [_, a, b] = match
      String.to_integer(a) * String.to_integer(b)
    end)
    |> Enum.sum()
  end

  def part2(input) do
    _parse_instructions(input)
    |> Enum.reduce({0, true}, fn instruction, state ->
      {value, doing} = state

      case instruction do
        [:do] ->
          {value, true}

        [:dont] ->
          {value, false}

        [:mul, a, b] ->
          if doing do
            {value + a * b, true}
          else
            {value, false}
          end
      end
    end)
  end

  defp _parse_instructions(input) do
    pattern = ~r"mul\((\d+),(\d+)\)|do\(\)|don't\(\)"

    Regex.scan(pattern, input)
    |> Enum.map(fn match ->
      {instruction, args} = List.pop_at(match, 0)
      args = Enum.map(args, &String.to_integer/1)

      cond do
        String.starts_with?(instruction, "mul") -> [:mul] ++ args
        instruction == "do()" -> [:do]
        instruction == "don't()" -> [:dont]
      end
    end)
  end
end

defmodule Aoc2024Elixir.Day4 do
  def testdata do
    """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """
  end

  defmodule Vector do
    defstruct x: 0, y: 0

    def new(x, y) do
      %Vector{x: x, y: y}
    end

    def add(a, b) do
      %Vector{x: a.x + b.x, y: a.y + b.y}
    end

    def negate(v) do
      %Vector{x: -v.x, y: -v.y}
    end

    def mul(v, i) do
      %Vector{x: v.x * i, y: v.y * i}
    end

    def zero() do
      %Vector{x: 0, y: 0}
    end
  end

  defmodule Grid do
    defstruct size: %Vector{x: 0, y: 0},
              _rows: []

    @spec new(list()) :: %Aoc2024Elixir.Day4.Grid{
            _rows: list(),
            size: %Aoc2024Elixir.Day4.Vector{x: non_neg_integer(), y: non_neg_integer()}
          }
    def new(rows) do
      size = %Vector{
        y: length(rows),
        x: length(Enum.at(rows, 0))
      }

      %Grid{size: size, _rows: rows}
    end

    def get_at(grid, pos) do
      Enum.at(grid._rows, pos.y)
      |> Enum.at(pos.x)
    end

    def contains_pos(grid, pos) do
      0 <= pos.x and pos.x < grid.size.x and 0 <= pos.y and pos.y < grid.size.y
    end

    def get_row_values(grid, row) do
      Stream.map(row, &get_at(grid, &1))
    end

    def get_row_coords(grid, isect, dir) do
      Stream.resource(
        fn ->
          start_dir = Vector.negate(dir)
          find_edge(grid, isect, start_dir)
        end,
        fn pos ->
          if contains_pos(grid, pos) do
            {[pos], Vector.add(pos, dir)}
          else
            {:halt, nil}
          end
        end,
        fn _ ->
          nil
        end
      )
    end

    def find_edge(grid, pos, dir) do
      x_dist =
        cond do
          # Ensure that x direction isn't selected.
          dir.x == 0 -> grid.size.y + 1
          dir.x == 1 -> grid.size.x - pos.x - 1
          dir.x == -1 -> pos.x
        end

      y_dist =
        cond do
          # Ensure that y direction isn't selected.
          dir.y == 0 -> grid.size.x + 1
          dir.y == 1 -> grid.size.y - pos.y - 1
          dir.y == -1 -> pos.y
        end

      nearest_dist = Enum.sort([x_dist, y_dist]) |> List.first()
      diff = Vector.mul(dir, nearest_dist)
      Vector.add(pos, diff)
    end
  end

  def part1(input) do
    grid = Grid.new(_parse_input(input))
    word = [:X, :M, :A, :S]

    all_row_coords_p1(grid)
    |> Stream.map(fn row ->
      Grid.get_row_values(grid, row)
    end)
    |> Stream.map(&count_word_in_row(&1, word))
    |> Enum.sum()
  end

  def part2(input) do
    grid = Grid.new(_parse_input(input))

    for x <- 1..(grid.size.x - 2),
        y <- 1..(grid.size.y - 2) do
      eks = get_eks_at(grid, Vector.new(x, y))

      if eks.c == :A do
        nesw = [eks.ne, eks.sw]
        nwse = [eks.nw, eks.se]

        if :M in nesw and :S in nesw and :M in nwse and :S in nwse do
          1
        else
          0
        end
      else
        0
      end
    end
    |> Enum.sum()
  end

  def get_eks_at(grid, pos) do
    %{
      c: Grid.get_at(grid, pos),
      nw: Grid.get_at(grid, Vector.add(pos, Vector.new(-1, -1))),
      ne: Grid.get_at(grid, Vector.add(pos, Vector.new(1, -1))),
      sw: Grid.get_at(grid, Vector.add(pos, Vector.new(-1, 1))),
      se: Grid.get_at(grid, Vector.add(pos, Vector.new(1, 1)))
    }
  end

  def all_row_coords_p1(grid) do
    gsx = grid.size.x - 1
    gsy = grid.size.y - 1

    east_west =
      0..gsy |> Stream.map(&Grid.get_row_coords(grid, Vector.new(0, &1), Vector.new(1, 0)))

    west_east =
      0..gsy |> Stream.map(&Grid.get_row_coords(grid, Vector.new(0, &1), Vector.new(-1, 0)))

    north_south =
      0..gsx |> Stream.map(&Grid.get_row_coords(grid, Vector.new(&1, 0), Vector.new(0, 1)))

    south_north =
      0..gsx |> Stream.map(&Grid.get_row_coords(grid, Vector.new(&1, 0), Vector.new(0, -1)))

    northwest_southeast =
      0..(gsx + gsy)
      |> Stream.map(
        &Grid.get_row_coords(
          grid,
          Vector.new(min(&1, gsx), min(gsy, gsx + gsy - &1)),
          Vector.new(1, 1)
        )
      )

    southeast_northwest =
      0..(gsx + gsy)
      |> Stream.map(
        &Grid.get_row_coords(
          grid,
          Vector.new(min(&1, gsx), min(gsy, gsx + gsy - &1)),
          Vector.new(-1, -1)
        )
      )

    southwest_northeast =
      0..(gsx + gsy)
      |> Stream.map(
        &Grid.get_row_coords(
          grid,
          Vector.new(min(&1, gsx), max(0, &1 - gsx)),
          Vector.new(1, -1)
        )
      )

    northeast_southwest =
      0..(gsx + gsy)
      |> Stream.map(
        &Grid.get_row_coords(
          grid,
          Vector.new(min(&1, gsx), max(0, &1 - gsx)),
          Vector.new(-1, 1)
        )
      )

    Stream.concat([
      east_west,
      west_east,
      north_south,
      south_north,
      northwest_southeast,
      southeast_northwest,
      northeast_southwest,
      southwest_northeast
    ])
  end

  def count_word_in_row(row, word) do
    Stream.chunk_every(row, length(word), 1)
    |> Stream.filter(&(&1 == word))
    |> Enum.count()
  end

  defp _parse_input(input) do
    String.trim(input)
    |> String.split("\n")
    |> Stream.map(&String.to_charlist/1)
    |> Enum.map(fn charlist ->
      Enum.map(charlist, fn char ->
        case char do
          88 -> :X
          77 -> :M
          65 -> :A
          83 -> :S
        end
      end)
    end)
  end
end
