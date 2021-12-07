defmodule DaySix do
  def get_input do
    {:ok, data} = File.read('input')

    data
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def part_one(data), do: get_population_count(data, init_cache(data), 80)

  def part_two(data), do: get_population_count(data, init_cache(data), 256)

  def init_cache(data) do
    0..8
    |> Enum.reduce(Enum.frequencies(data), fn element, cache_acc ->
      cond do
        Map.has_key?(cache_acc, element) ->
          cache_acc

        true ->
          Map.put(cache_acc, element, 0)
      end
    end)
  end

  def get_population_count(_, cache, 0),
    do: cache |> Enum.reduce(0, fn {_, population_count}, sum -> sum + population_count end)

  def get_population_count(data, cache, days) do
    cache_updated =
      cache
      |> Enum.reduce(cache, fn {timer_key, density}, cache_acc ->
        cond do
          timer_key === 0 ->
            cache_acc
            |> Map.put(0, Map.get(cache_acc, 0) - density)
            |> Map.put(6, Map.get(cache_acc, 6) + density)
            |> Map.put(8, Map.get(cache_acc, 8) + density)

          true ->
            cache_acc
            |> Map.put(timer_key, Map.get(cache_acc, timer_key) - density)
            |> Map.put(timer_key - 1, Map.get(cache_acc, timer_key - 1) + density)
        end
      end)

    get_population_count(data, cache_updated, days - 1)
  end

  def run do
    data = get_input()
    {part_one_time_micro, part_one_result} = :timer.tc(fn -> part_one(data) end)
    {part_two_time_micro, part_two_result} = :timer.tc(fn -> part_two(data) end)
    IO.puts('Part one: #{part_one_result}, #{part_one_time_micro / 1000} ms.')
    IO.puts('Part two: #{part_two_result}, #{part_two_time_micro / 1000} ms.')
  end
end

DaySix.run()
