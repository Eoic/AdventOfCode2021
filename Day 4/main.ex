defmodule DayFour do
  @size 5
  @dimensions 2

  def get_input do
    {:ok, data} = File.read('input')

    [input | boards] =
      data
      |> String.trim()
      |> String.split("\n\n")

    boards_parsed =
      boards
      |> Enum.map(fn board ->
        board
        |> String.split()
        |> Enum.map(&String.to_integer/1)
        |> Enum.chunk_every(5)
      end)

    input_parsed =
      input
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    [input_parsed, boards_parsed]
  end

  def part_one(input, boards) do
    get_score(input, boards, &Enum.min_by/2)
  end

  def part_two(input, boards) do
    get_score(input, boards, &Enum.max_by/2)
  end

  def get_score(input, boards, selector) do
    [lookup_table, last_hit_value, _] =
      boards
      |> Enum.map(fn board ->
        counter = create_counter(@dimensions, @size)
        lookup_table = create_lookup(board)
        fill(input, lookup_table, counter, 0)
      end)
      |> selector.(fn element ->
        [_, _, step_count] = element
        step_count
      end)

    compute_score(lookup_table, last_hit_value)
  end

  def compute_score(lookup_table, last_hit_value) do
    sum =
      lookup_table
      |> Enum.reduce(0, fn {value, position}, sum ->
        if position !== :hit, do: sum + value, else: sum
      end)

    last_hit_value * sum
  end

  def fill([hit_value | queue], lookup_table, counter, step_count) do
    position = Map.get(lookup_table, hit_value)

    case position do
      nil ->
        fill(queue, lookup_table, counter, step_count + 1)

      _ ->
        [row, column] = position

        counter_updated =
          [row, column]
          |> Enum.with_index()
          |> Enum.reduce(counter, fn {position, dimension_index}, counter_acc ->
            dimension_counter = Map.get(counter_acc, dimension_index)
            dimension_value = Map.get(dimension_counter, position)
            dimension_counter_updated = Map.put(dimension_counter, position, dimension_value + 1)
            Map.put(counter_acc, dimension_index, dimension_counter_updated)
          end)

        lookup_table_updated = lookup_table |> Map.put(hit_value, :hit)

        is_full =
          [row, column]
          |> Enum.with_index()
          |> Enum.any?(fn {position, dimension} ->
            counter_updated |> Map.get(dimension) |> Map.get(position) === 5
          end)

        if is_full,
          do: [lookup_table_updated, hit_value, step_count],
          else: fill(queue, lookup_table_updated, counter_updated, step_count + 1)
    end
  end

  def create_lookup(board) do
    board
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, row_index}, upper_acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(upper_acc, fn {value, col_index}, lower_acc ->
        Map.put(lower_acc, value, [row_index, col_index])
      end)
    end)
  end

  def create_counter(dimensions, matrix_size) do
    Enum.reduce(0..(dimensions - 1), %{}, fn dim, acc_dim ->
      Enum.reduce(0..(matrix_size - 1), %{}, &Map.put(&2, &1, 0))
      |> (&Map.put(acc_dim, dim, &1)).()
    end)
  end

  def get_hit_count(counter) do
    0..1
    |> Enum.reduce(0, fn dimension, dim_sum ->
      counter
      |> Map.get(dimension)
      |> Enum.reduce(dim_sum, fn {_, hit_count}, sum -> sum + hit_count end)
    end)
  end

  def run do
    {input_time, [input, boards]} = :timer.tc(fn -> get_input() end)
    {part_one_time, part_one_res} = :timer.tc(fn -> part_one(input, boards) end)
    {part_two_time, part_two_res} = :timer.tc(fn -> part_two(input, boards) end)
    IO.puts('Input: #{input_time / 1000} ms.')
    IO.puts('Part one: #{part_one_res}, #{part_one_time / 1000} ms.')
    IO.puts('Part two: #{part_two_res}, #{part_two_time / 1000} ms.')
  end
end

DayFour.run()
