defmodule DayTwo do
  def get_input do
    {:ok, data} = File.read('input')

    data
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn token ->
      [direction, distance] = String.split(token)
      {distance_int, ""} = Integer.parse(distance)
      [direction, distance_int]
    end)
  end

  def part_one(data, horizontal_position \\ 0, depth \\ 0)

  def part_one([], horizontal_position, depth) do
    Enum.product([horizontal_position, depth])
  end

  def part_one(data, horizontal_position, depth) do
    [head | tail] = data
    [direction, distance] = head

    cond do
      direction == "forward" -> part_one(tail, horizontal_position + distance, depth)
      direction == "down" -> part_one(tail, horizontal_position, depth + distance)
      direction == "up" -> part_one(tail, horizontal_position, depth - distance)
    end
  end

  def part_two(data, horizontal_position \\ 0, depth \\ 0, aim \\ 0)

  def part_two([], horizontal_position, depth, _) do
    Enum.product([horizontal_position, depth])
  end

  def part_two(data, horizontal_position, depth, aim) do
    [head | tail] = data
    [direction, distance] = head

    cond do
      direction == "forward" -> part_two(tail, horizontal_position + distance, depth + aim * distance, aim)
      direction == "down" -> part_two(tail, horizontal_position, depth, aim + distance)
      direction == "up" -> part_two(tail, horizontal_position, depth, aim - distance)
    end
  end

  def run do
    data = get_input()
    IO.puts('Part one: #{part_one(data)}')
    IO.puts('Part two: #{part_two(data)}')
  end
end

DayTwo.run()
