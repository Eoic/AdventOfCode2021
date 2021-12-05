defmodule DayFive do
  def get_input do
    {:ok, data} = File.read('input')

    data
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(" -> ")
      |> Enum.map(fn pair ->
        pair
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)
    end)
  end

  def part_one(data), do: count_points(data, %{}, false)

  def part_two(data), do: count_points(data, %{}, true)

  def count_points([], points_counter, include_diagonals) do
    points_counter |> Enum.reduce(0, fn {_, hits}, sum -> sum + if hits > 1, do: 1, else: 0 end)
  end

  def count_points([line | queue], points_counter, include_diagonals) do
    [[x1, y1], [x2, y2]] = line
    x_delta = abs(x2 - x1)
    y_delta = abs(y2 - y1)
    x_direction = if x1 > x2, do: -1, else: 1
    y_direction = if y1 > y2, do: -1, else: 1
    x_range = if x_delta > 0, do: 0..x_delta, else: []
    y_range = if y_delta > 0, do: 0..y_delta, else: []

    [range, apply_delta] =
      cond do
        x1 === x2 ->
          [y_range, fn x, y, delta -> [x, y + delta * y_direction] end]

        y1 === y2 ->
          [x_range, fn x, y, delta -> [x + delta * x_direction, y] end]

        include_diagonals ->
          [x_range, fn x, y, delta -> [x + delta * x_direction, y + delta * y_direction] end]

        true ->
          [[], fn x, y, delta -> [x, y] end]
      end

    points_counter_updated =
      range
      |> Enum.reduce(points_counter, fn delta, points_counter_acc ->
        [xn, yn] = apply_delta.(x1, y1, delta)
        count = Map.get(points_counter_acc, [xn, yn], 0)
        Map.put(points_counter_acc, [xn, yn], count + 1)
      end)

    count_points(queue, points_counter_updated, include_diagonals)
  end

  def run do
    data = get_input()
    IO.puts('Part one: #{part_one(data)}.')
    IO.puts('Part two: #{part_two(data)}.')
  end
end

DayFive.run()
