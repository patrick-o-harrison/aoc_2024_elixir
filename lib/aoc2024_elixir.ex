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
    |> Stream.zip
    |> Stream.map(fn p ->
      {a, b} = p
      abs(a - b)
    end)
    |> Enum.reduce(0, & &1 + &2)
  end

  @spec part2(binary())::integer()
  def part2(input) do
    [list_a, list_b] = _parse_input(input) |> Enum.to_list
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
    |> Stream.zip
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
      :false
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
    Stream.zip(list, Stream.take(list, -length(list)+1))
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
    |> Enum.sum
  end

  def part2(input) do
    _parse_instructions(input)
    |> Enum.reduce({0, true}, fn instruction, state ->
      {value, doing} = state
      case instruction do
        [:do] -> {value, true}
        [:dont] -> {value, false}
        [:mul, a, b] -> if doing do
          {value + (a * b), true}
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
    MMMSXXMASS
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


  def part1(input) do
    grid = _parse_input(input)
    {width, height} = _grid_dimensions(grid)
    word = [:X, :M, :A, :S]
    for y <- 0..(height-1), x <- 0..(width-1) do
      _possible_directions(word, width, height, x, y)
      |> Stream.map(fn direction ->
        _find_word(grid, x, y, word, direction)
        |> tap(fn found ->
          if _get_at(grid, x, y) == :X do
            IO.inspect(found, label: inspect({x, y, direction}))
          end
        end)
      end)
      |> Enum.count(& &1)
    end
    |> Enum.sum
  end

  defp _directions do
    [
      [:north],
      [:north, :east],
      [:east],
      [:south, :east],
      [:south],
      [:south, :west],
      [:west],
      [:north, :west]
    ]
  end

  defp _possible_directions(word, width, height, x, y) do
    word_length = length(word)
    possible_cardinals =
      (if y - word_length + 1 >= 0, do: [:north], else: []) ++
      (if y + word_length < height, do: [:south], else: []) ++
      (if x - word_length + 1 >= 0, do: [:west], else: []) ++
      (if x + word_length < width, do: [:east], else: [])
    Enum.filter(_directions(), fn direction ->
      Enum.all?(direction, & &1 in possible_cardinals)
    end)
  end

  defp _grid_dimensions(grid) do
    height = length(grid)
    width = length(Enum.at(grid, 0))
    {width, height}
  end

  defp _get_at(grid, x, y) do
    Enum.at(grid, y)
    |> Enum.at(x)
  end

  defp _find_word(grid, x, y, word, direction) do
    {letter, rest} = List.pop_at(word, 0)
    cell_letter = _get_at(grid, x, y)
    if letter != cell_letter do
      false
    else
      if rest == [] do
        true
      else
        new_x = cond do
          :west in direction -> x - 1
          :east in direction -> x + 1
          true -> x
        end
        new_y = cond do
          :north in direction -> y - 1
          :south in direction -> y + 1
          true -> y
        end
        _find_word(grid, new_x, new_y, rest, direction)
      end
    end
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
