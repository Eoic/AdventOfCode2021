defmodule DayTen do
  @input_path "input"
  @token_map %{"(" => ")", "[" => "]", "<" => ">", "{" => "}"}
  @score_map_missing %{")" => 1, "]" => 2, ">" => 4, "}" => 3}
  @score_map_errors %{")" => 3, "]" => 57, ">" => 25137, "}" => 1197}

  def get_input do
    {:ok, data} = File.read(@input_path)

    data
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  def part_one(data) do
    data
    |> Enum.reduce(0, fn line, sum ->
      {invalid_token, _} = validate_line(line, @token_map, [])
      sum + Map.get(@score_map_errors, invalid_token, 0)
    end)
  end

  def part_two(data) do
    scores =
      data
      |> Enum.reduce([], fn line, scores ->
        {invalid_token, token_stack} = validate_line(line, @token_map, [])

        case invalid_token do
          nil ->
            [
              Enum.reduce(token_stack, 0, fn token, line_score ->
                line_score * 5 + Map.get(@score_map_missing, Map.get(@token_map, token))
              end)
              | scores
            ]
          _ ->
            scores
        end
      end)
      |> Enum.sort()

    Enum.at(scores, scores |> Enum.count() |> div(2))
  end

  def validate_line([], _, token_stack), do: {nil, token_stack}

  def validate_line([token | queue], token_map, token_stack) do
    if token in Map.keys(token_map) do
      validate_line(queue, token_map, [token | token_stack])
    else
      [next_token | token_stack_tail] = token_stack

      cond do
        Map.get(token_map, next_token) !== token -> {token, token_stack}
        true -> validate_line(queue, token_map, token_stack_tail)
      end
    end
  end

  def run do
    data = get_input()
    {part_one_time_micro, part_one_result} = :timer.tc(fn -> part_one(data) end)
    {part_two_time_micro, part_two_result} = :timer.tc(fn -> part_two(data) end)
    IO.puts('Part one: #{part_one_result}, #{part_one_time_micro / 1000} ms.')
    IO.puts('Part two: #{part_two_result}, #{part_two_time_micro / 1000} ms.')
  end
end

DayTen.run()
