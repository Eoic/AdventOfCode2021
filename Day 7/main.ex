defmodule DaySeven do
  def get_input do
    {:ok, data} = File.read('input')

    data
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def part_one(data), do: get_shortest_distance(data, false)

  def part_two(data), do: get_shortest_distance(data, true)

  def get_shortest_distance(data, incremental_spending) do
    {minPos, maxPos} = Enum.min_max(data)
    frequency_table = Enum.frequencies(data)

    minPos..maxPos
    |> Enum.map(fn position ->
      frequency_table
      |> Enum.reduce(0, fn {freq_pos, count}, distance_acc ->
        abs_distance = abs(position - freq_pos)

        cond do
          incremental_spending ->
            distance_acc + abs_distance * ((abs_distance + 1) / 2) * count

          true ->
            distance_acc + abs_distance * count
        end
      end)
    end)
    |> Enum.min()
  end

  def run do
    data = get_input()
    {part_one_time_micro, part_one_result} = :timer.tc(fn -> part_one(data) end)
    {part_two_time_micro, part_two_result} = :timer.tc(fn -> part_two(data) end)
    IO.puts('Part one: #{part_one_result}, #{part_one_time_micro / 1000} ms.')
    IO.puts('Part two: #{part_two_result}, #{part_two_time_micro / 1000} ms.')
  end
end

DaySeven.run()
