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
    row_length = data |> Enum.count()
    col_length = data |> Enum.at(0) |> Enum.count()

    data
    |> Enum.with_index()
    |> Enum.reduce(0, fn {row, row_index}, sum_acc ->
      sum =
        row
        |> Enum.with_index()
        |> Enum.reduce([], fn {col, col_index}, lowest_elements_acc ->
          current_element = col

          is_lowest =
            [
              [row_index, col_index - 1],
              [row_index, col_index + 1],
              [row_index + 1, col_index],
              [row_index - 1, col_index]
            ]
            |> Enum.filter(fn [w_row_index, w_col_index] ->
              w_row_index >= 0 && w_col_index >= 0 && w_col_index < col_length &&
                w_row_index < row_length
            end)
            |> Enum.all?(fn [w_row_index, w_col_index] ->
              element = Enum.at(data, w_row_index) |> Enum.at(w_col_index)
              current_element < element
            end)

          if is_lowest do
            [current_element + 1 | lowest_elements_acc]
          else
            lowest_elements_acc
          end
        end)
        |> Enum.sum()

      sum_acc + sum
    end)
  end

  def part_two(data) do
    nil
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
