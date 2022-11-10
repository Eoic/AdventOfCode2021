defmodule Octopus do
  defstruct energy: 0, flashes: 0, is_flashed: false
end

defmodule DayEleven do
  @input_path "input"

  def get_input do
    {:ok, data} = File.read(@input_path)

    data
    |> String.trim()
    |> String.split("\r\n")
    |> Enum.map(fn row ->
      row
      |> String.graphemes
      |> Enum.map(fn token -> %Octopus{energy: String.to_integer(token)} end)
    end)
  end

  def part_one(data, bounds) do
    simulate_steps(data, bounds, 100) |> sum_flashes()
  end

  def part_two(data, bounds) do
    simulate_until_sync(data, bounds)
  end

  def is_all_flashing(data) do
    Enum.all?(data, fn row ->
      Enum.all?(row, fn octopus ->
        Map.get(octopus, :is_flashed)
      end)
    end)
  end

  def simulate_until_sync(data, bounds, step_id \\ 0)

  def simulate_until_sync(data, bounds, step_id) do
    cond do
      is_all_flashing(data) ->
        step_id
      true ->
        step(data) |> simulate_flash(bounds) |> simulate_until_sync(bounds, step_id + 1)
    end
  end

  def simulate_steps(data, _, 0), do: data

  def simulate_steps(data, bounds, steps) do
    step(data) |> simulate_flash(bounds) |> simulate_steps(bounds, steps - 1)
  end

  def sum_flashes(data) do
    Enum.reduce(data, 0, fn row, total_sum ->
      Enum.reduce(row, total_sum, fn octopus, row_sum ->
        row_sum + Map.get(octopus, :flashes)
      end)
    end)
  end

  def simulate_flash(data, bounds) do
    point = get_pending_flash_point(data)

    cond do
      is_point_empty(point) ->
        data
      true ->
        apply_flash(data, point, bounds) |> simulate_flash(bounds)
    end
  end

  def step(data) do
    Enum.map(data, fn row ->
      Enum.map(row, fn octopus ->
        %{octopus | energy: Map.get(octopus, :energy) + 1, is_flashed: false}
      end)
    end)
  end

  def is_point_empty(point) do
    Map.get(point, :x) === nil or Map.get(point, :y) === nil
  end

  def is_point_valid([x, y], %{:min_x => min_x, :min_y => min_y, :max_x => max_x, :max_y => max_y}) do
    x >= min_x and x <= max_x and y >= min_y and y <= max_y
  end

  def get_pending_flash_point(data) do
    width = length(data)
    height = length(Enum.at(data, 0))

    0..width - 1 |> Enum.reduce_while(%{x: nil, y: nil}, fn y, point ->
      row_point = 0..height - 1 |> Enum.reduce_while(point, fn x, point ->
        %{:energy => energy, :is_flashed => is_flashed} = Enum.at(data, y) |> Enum.at(x)

        cond do
          energy > 9 and not is_flashed ->
            {:halt, %{point | x: x, y: y}}
          true ->
            {:cont, point}
        end
      end)

      if is_point_empty(row_point) do
        {:cont, row_point}
      else
        {:halt, row_point}
      end
    end)
  end

  def generate_adjacent_points(%{:x => x, :y => y}) do
    [
      [x - 1, y - 1],
      [x,     y - 1],
      [x + 1, y - 1],
      [x + 1, y    ],
      [x + 1, y + 1],
      [x,     y + 1],
      [x - 1, y + 1],
      [x - 1, y    ]
    ]
  end

  def flash_at_point(data, %{:x => x, :y => y}) do
    row = Enum.at(data, y)
    octopus = Enum.at(row, x)
    List.replace_at(data, y, List.replace_at(row, x, %{octopus | energy: 0, is_flashed: true, flashes: Map.get(octopus, :flashes) + 1}))
  end

  def apply_flash(data, point, bounds) do
    generate_adjacent_points(point)
    |> Enum.filter(fn adjacent_point -> is_point_valid(adjacent_point, bounds) end)
    |> Enum.reduce(data, fn [x, y], data ->
      row = Enum.at(data, y)
      octopus = Enum.at(row, x)

      cond do
        not Map.get(octopus, :is_flashed) ->
          List.replace_at(data, y, List.replace_at(row, x, %{octopus | energy: Map.get(octopus, :energy) + 1}))
        true ->
          data
      end
    end)
    |> flash_at_point(point)
  end

  def run do
    data = get_input()
    bounds = %{min_x: 0, min_y: 0, max_x: length(Enum.at(data, 0)) - 1, max_y: length(data) - 1}
    IO.puts("Part one: #{part_one(data, bounds)}")
    IO.puts("Part two: #{part_two(data, bounds)}")
  end
end

DayEleven.run()
