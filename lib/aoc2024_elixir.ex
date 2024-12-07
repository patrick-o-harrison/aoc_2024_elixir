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
