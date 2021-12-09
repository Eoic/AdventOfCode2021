defmodule DayEight do
  @input_path "input"

  @permutations [
    [1, 0, 0, 1, 1, 0],
    [1, 0, 0, 1, 0, 1],
    [1, 0, 1, 0, 1, 0],
    [1, 0, 1, 0, 0, 1],
    [0, 1, 0, 1, 1, 0],
    [0, 1, 0, 1, 0, 1],
    [0, 1, 1, 0, 1, 0],
    [0, 1, 1, 0, 0, 1]
  ]

  @segments_map %{
    0 => [0, 1, 3, 4, 5, 6],
    1 => [5, 6],
    2 => [0, 2, 3, 4, 6],
    3 => [0, 2, 4, 5, 6],
    4 => [1, 2, 5, 6],
    5 => [0, 1, 2, 4, 5],
    6 => [0, 1, 2, 3, 4, 5],
    7 => [0, 5, 6],
    8 => [0, 1, 2, 3, 4, 5, 6],
    9 => [0, 1, 2, 4, 5, 6]
  }

  def get_input do
    {:ok, data} = File.read(@input_path)

    data
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " | "))
  end

  def part_one(data) do
    total_count =
      data
      |> Enum.reduce(0, fn [_, output], count_acc ->
        count =
          output
          |> String.split(" ")
          |> Enum.filter(&(String.graphemes(&1) |> Enum.count() |> contains_length()))
          |> Enum.count()

        count_acc + count
      end)

    total_count
  end

  def part_two(data) do
    segments_map_inverse = Enum.into(@segments_map, %{}, &{elem(&1, 1), elem(&1, 0)})

    data
    |> Enum.map(fn [input, output] ->
      input_split = String.split(input, " ")
      output_split = String.split(output, " ")
      segments = create_segments_map(input_split)

      tbr =
        segments
        |> Map.get(1)
        |> Enum.to_list()

      tlm =
        MapSet.difference(
          Map.get(segments, 4),
          Map.get(segments, 1)
        )
        |> Enum.to_list()

      top =
        MapSet.difference(
          Map.get(segments, 7),
          Map.get(segments, 1)
        )
        |> Enum.to_list()

      bbl =
        MapSet.union(
          Map.get(segments, 4),
          Map.get(segments, 7)
        )
        |> (&MapSet.difference(Map.get(segments, 8), &1)).()
        |> Enum.to_list()

      create_display_configurations(
        @permutations,
        %{0 => top, 1 => tlm, 2 => tlm, 3 => bbl, 4 => bbl, 5 => tbr, 6 => tbr},
        @segments_map,
        []
      )
      |> Enum.find(&validate_input(&1, @segments_map, input_split))
      |> decode_output_display(segments_map_inverse, output_split, [])
      |> Enum.join()
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  def contains_length(element) do
    Enum.member?([2, 3, 4, 7], element)
  end

  def create_segments_map(input) do
    input
    |> Enum.reduce(%{}, fn element, segment_map ->
      case element |> String.graphemes() |> Enum.count() do
        2 -> Map.put(segment_map, 1, element |> String.graphemes() |> MapSet.new())
        3 -> Map.put(segment_map, 7, element |> String.graphemes() |> MapSet.new())
        4 -> Map.put(segment_map, 4, element |> String.graphemes() |> MapSet.new())
        7 -> Map.put(segment_map, 8, element |> String.graphemes() |> MapSet.new())
        _ -> segment_map
      end
    end)
  end

  def decode_output_display(_, _, [], output), do: Enum.reverse(output)

  def decode_output_display(config, segments_map_inverse, [output_segment | queue], output) do
    positions =
      output_segment
      |> String.graphemes()
      |> Enum.map(&Map.get(config, &1))
      |> Enum.sort()

    matching_number = Map.get(segments_map_inverse, positions)
    decode_output_display(config, segments_map_inverse, queue, [matching_number | output])
  end

  def validate_input(_, _, []), do: true

  def validate_input(config, @segments_map, [input_number | queue]) do
    positions =
      input_number
      |> String.graphemes()
      |> Enum.map(&Map.get(config, &1))
      |> Enum.sort()

    matches =
      0..9
      |> Enum.reduce_while(0, fn number, match_count ->
        number_positions_ref = Map.get(@segments_map, number)

        cond do
          match_count > 1 -> {:halt, match_count}
          positions == number_positions_ref -> {:cont, match_count + 1}
          true -> {:cont, match_count}
        end
      end)

    if matches === 1, do: validate_input(config, @segments_map, queue), else: false
  end

  def create_display_configurations([], _, _, configurations), do: configurations

  def create_display_configurations(
        [current_alignment_indices | queue],
        segment_reference,
        @segments_map,
        configurations
      ) do
    segment_alignment =
      current_alignment_indices
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {perm_index, index}, segment_acc ->
        segment_name = Map.get(segment_reference, index + 1) |> Enum.at(perm_index)
        Map.put(segment_acc, segment_name, index + 1)
      end)

    create_display_configurations(
      queue,
      segment_reference,
      @segments_map,
      [
        Map.put(segment_alignment, Map.get(segment_reference, 0) |> Enum.at(0), 0)
        | configurations
      ]
    )
  end

  def run do
    data = get_input()
    {part_one_time_micro, part_one_result} = :timer.tc(fn -> part_one(data) end)
    {part_two_time_micro, part_two_result} = :timer.tc(fn -> part_two(data) end)
    IO.puts('Part one: #{part_one_result}, #{part_one_time_micro / 1000} ms.')
    IO.puts('Part two: #{part_two_result}, #{part_two_time_micro / 1000} ms.')
  end
end

DayEight.run()
