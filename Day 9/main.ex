defmodule DayNine do
  @input_path "input"

  def get_input do
    {:ok, data} = File.read(@input_path)

    data
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn element -> String.graphemes(element) |> Enum.map(&String.to_integer/1) end)
  end

  def part_one(data) do
    get_lowest_points(data) |> Enum.reduce(0, fn %{element: value}, sum -> sum + value + 1 end)
  end

  def part_two(data) do
    row_length = data |> Enum.count()
    col_length = data |> Enum.at(0) |> Enum.count()
    visited_positions_map = create_visited_positions_map(data)

    get_lowest_points(data)
    |> Enum.map(fn %{position: lowest_position} ->
      fill([row_length, col_length], data, visited_positions_map, [lowest_position])
    end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  def create_visited_positions_map(data) do
    data
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, row_index}, positions_map_outer ->
      row
      |> Enum.with_index()
      |> Enum.reduce(positions_map_outer, fn {element, column_index}, positions_map_inner ->
        is_visited = if element === 9, do: true, else: false
        Map.put(positions_map_inner, [row_index, column_index], is_visited)
      end)
    end)
  end

  def get_adjacent_positions(row_index, column_index) do
    [
      [row_index, column_index - 1],
      [row_index, column_index + 1],
      [row_index + 1, column_index],
      [row_index - 1, column_index]
    ]
  end

  def fill(size, data, visited_positions, queued_positions, basin_size \\ 0)

  def fill(_, _, _, [], basin_size), do: basin_size

  def fill(size, data, visited_positions, [next_position | queued_positions], basin_size) do
    [row_length, column_length] = size
    [row_index, column_index] = next_position

    next_positions =
      get_adjacent_positions(row_index, column_index)
      |> Enum.filter(fn [row, column] ->
        is_visited = Map.get(visited_positions, [row, column])
        is_queued = Enum.member?(queued_positions, [row, column])
        is_length_valid = row >= 0 && column >= 0 && column < column_length && row < row_length
        !is_queued && !is_visited && is_length_valid
      end)

    fill(
      size,
      data,
      Map.put(visited_positions, [row_index, column_index], true),
      next_positions ++ queued_positions,
      basin_size + 1
    )
  end

  def get_lowest_points(data) do
    row_length = data |> Enum.count()
    col_length = data |> Enum.at(0) |> Enum.count()

    data
    |> Enum.with_index()
    |> Enum.reduce([], fn {row, row_index}, lowest_elements ->
      lowest_row_elements =
        row
        |> Enum.with_index()
        |> Enum.reduce([], fn {col, col_index}, lowest_elements_per_column ->
          current_element = col

          is_lowest =
            [
              [row_index, col_index - 1],
              [row_index, col_index + 1],
              [row_index + 1, col_index],
              [row_index - 1, col_index]
            ]
            |> Enum.filter(fn [w_row_index, w_col_index] ->
              w_row_index >= 0 &&
                w_col_index >= 0 &&
                w_col_index < col_length &&
                w_row_index < row_length
            end)
            |> Enum.all?(fn [w_row_index, w_col_index] ->
              element = Enum.at(data, w_row_index) |> Enum.at(w_col_index)
              current_element < element
            end)

          if is_lowest do
            [
              %{
                :element => current_element,
                :position => [row_index, col_index]
              }
              | lowest_elements_per_column
            ]
          else
            lowest_elements_per_column
          end
        end)

      lowest_row_elements ++ lowest_elements
    end)
  end

  def run do
    data = get_input()
    {part_one_time_micro, part_one_result} = :timer.tc(fn -> part_one(data) end)
    {part_two_time_micro, part_two_result} = :timer.tc(fn -> part_two(data) end)
    IO.puts('Part one: #{part_one_result}, #{part_one_time_micro / 1000} ms.')
    IO.puts('Part two: #{part_two_result}, #{part_two_time_micro / 1000} ms.')
  end
end

DayNine.run()
