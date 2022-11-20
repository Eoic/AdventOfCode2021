defmodule DayThirteen do
  @input_path "input"

  def get_input do
    {:ok, data} = File.read(@input_path)

    [template_str, instructions_str] =
      data
      |> String.trim()
      |> String.split("\r\n\r\n", trim: true)

    instructions =
      instructions_str
      |> String.split("\r\n")
      |> Enum.reduce(%{}, fn instruction_token, instructions_map ->
        %{"key" => key, "value" => value} =
          Regex.named_captures(~r/(?<key>[A-Z]+)(?:\s->\s)(?<value>[A-Z]+)/, instruction_token)

        Map.merge(instructions_map, %{key => value})
      end)

    pairs =
      template_str
      |> String.split("", trim: true)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&Enum.join/1)
      |> Enum.frequencies()

    [pairs: pairs, instructions: instructions]
  end

  def part_one(data, step_count \\ 10) do
    count_min_max_tokens(data, step_count)
  end

  def part_two(data, step_count \\ 40) do
    count_min_max_tokens(data, step_count)
  end

  def count_min_max_tokens(data, step_count) do
    [pairs: pairs, instructions: instructions] = data

    pairs
    |> simulate(instructions, step_count)
    |> count_tokens()
    |> normalize_token_frequency()
    |> get_min_max_diff()
  end

  def simulate(pairs, instructions, step_count) do
    1..step_count
      |> Enum.reduce(pairs, fn step_number, current_pairs ->
        apply_step(current_pairs, instructions)
      end)
  end

  def count_tokens(pairs) do
    pairs
    |> Map.keys()
    |> Enum.reduce(%{}, fn (pair_key, counts_map) ->
      pair_key
      |> String.split("", trim: true)
      |> Enum.reduce(counts_map, fn (token, acc) ->
        Map.update(acc, token, Map.get(pairs, pair_key), fn current_count ->
          current_count + Map.get(pairs, pair_key)
        end)
      end)
    end)
  end

  def apply_step(pairs, instructions) do
    pairs
    |> Map.keys()
    |> Enum.reduce(%{}, fn (pair_key, acc) ->
      apply_instruction(pairs, acc, pair_key, instructions)
    end)
  end

  def apply_instruction(pairs, pairs_acc, pair_key, instructions) do
    [prefix, suffix] = String.split(pair_key, "", trim: true)
    infix = Map.get(instructions, pair_key)

    pairs_acc
    |> Map.update(prefix <> infix, Map.get(pairs, pair_key), fn current_count -> current_count + Map.get(pairs, pair_key) end)
    |> Map.update(infix <> suffix, Map.get(pairs, pair_key), fn current_count -> current_count + Map.get(pairs, pair_key) end)
  end

  def normalize_token_frequency(frequency_map) do
    frequency_map
    |> Map.keys()
    |> Enum.reduce(frequency_map, fn (token, acc_frequency_map) ->
      Map.update!(acc_frequency_map, token, fn current_value -> round(current_value / 2) end)
    end)
  end

  def get_min_max_diff(pairs) do
    pairs
    |> Enum.min_max_by(fn {_key, value} -> value end)
    |> (fn ({{_, min}, {_, max}}) -> max - min end).()
  end

  def run do
    data = get_input()
    IO.puts("Part one: #{part_one(data)}")
    IO.puts("Part two: #{part_two(data)}")
  end
end

DayThirteen.run()
