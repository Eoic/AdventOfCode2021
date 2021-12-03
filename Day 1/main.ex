defmodule DayOne do
  def get_input do
    {:ok, data} = File.read('input')

    data
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn token ->
        {num, ""} = Integer.parse(String.trim(token))
        num
    end)
  end

  def part_one(data) do
    data
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.flat_map(fn [x, y] -> if x - y < 0, do: [:increased], else: [] end)
      |> Enum.count()
  end

  def part_two(data) do
    data
      |> Enum.chunk_every(3, 1, :discard)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.flat_map(fn [window_left, window_right] -> if Enum.sum(window_left) - Enum.sum(window_right) < 0, do: [:increased], else: [] end)
      |> Enum.count()
  end

  def run do
    data = get_input()
    IO.puts('Part one: #{part_one(data)}')
    IO.puts('Part two: #{part_two(data)}')
  end
end

DayOne.run()
