defmodule Aoc2024Day5 do
  def testdata do
    """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
    """
  end

  def part1(input) do
    {rules, lists} = parse_input(input)
    Enum.filter(lists, fn list ->
      list_valid(rules, list)
    end)
    |> Enum.map(fn list ->
      Enum.at(list, floor(length(list) / 2))
    end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum
  end

  def part2(input) do
    {rules, lists} = parse_input(input)
    Enum.filter(lists, fn list ->
      not list_valid(rules, list)
    end)
    |> Enum.map(& fix_list(rules, &1))
    |> Enum.map(fn list ->
      Enum.at(list, floor(length(list) / 2))
    end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum
  end

  def parse_input(input) do
    String.trim(input)
    [rules_txt, lists_txt] = String.split(input, "\n\n")
    rules_txt = String.trim(rules_txt)
    lists_txt = String.trim(lists_txt)

    rules =
      Regex.scan(~r"(\d+)\|(\d+)", rules_txt)
      |> Enum.map(fn rule ->
        [_, a, b] = rule
        Map.put(%{}, a, [b])
      end)
      |> Enum.reduce(%{}, fn rule, acc_rules ->
        Map.merge(rule, acc_rules, fn _k, v1, v2 -> v1 ++ v2 end)
      end)

    lists =
      String.split(lists_txt, "\n")
      |> Enum.map(fn list_txt ->
        String.split(list_txt, ",")
      end)

    {rules, lists}
  end

  def fix_list(rules, list) do
    Enum.sort(list, fn a, b ->
      b in Map.get(rules, a, [])
    end)
  end

  def list_valid(rules, list) do
    if length(list) == 0 do
      true
    else
      [page | rest] = list
      if Enum.any?(rest, fn rpage -> page in Map.get(rules, rpage, []) end) do
        false
      else
        list_valid(rules, rest)
      end

    end
  end
end
