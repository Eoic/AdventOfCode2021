use Bitwise

defmodule BinaryToDecimal do
  def convert(binary) do
    if is_bitstring(binary) do
      bit_list =
        String.graphemes(binary)
        |> Enum.map(fn char ->
          {bit_int, ""} = Integer.parse(char)
          bit_int
        end)

      parse(bit_list, 0)
    else
      parse(binary, 0)
    end
  end

  def parse([], sum), do: sum

  def parse(list, sum) do
    [head | tail] = list

    if head === 1,
      do: parse(tail, sum + (:math.pow(2, Enum.count(list) - 1) |> round)),
      else: parse(tail, sum)
  end
end

defmodule DayThree do
  def get_input do
    {:ok, data} = File.read('input')

    data
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn token -> token end)
  end

  def part_one(data) do
    half_length = div(Enum.count(data), 2)
    frequency = get_high_bit_frequency(data, half_length)
    gamma = Enum.map(frequency, fn {_, value} -> if value >= half_length, do: 1, else: 0 end)
    epsilon = Enum.map(gamma, fn bit -> if bit === 1, do: 0, else: 1 end)
    BinaryToDecimal.convert(gamma) * BinaryToDecimal.convert(epsilon)
  end

  def part_two(data) do
    oxygen_rating = get_rating(data, 0)
    co2_rating = get_rating(data, 1)
    BinaryToDecimal.convert(oxygen_rating) * BinaryToDecimal.convert(co2_rating)
  end

  def get_high_bit_count(numbers_list, position, high_bit_count \\ 0)

  def get_high_bit_count([], _, high_bit_count), do: high_bit_count

  def get_high_bit_count(numbers_list, position, high_bit_count) do
    [head | tail] = numbers_list
    get_high_bit_count(tail, position, high_bit_count + if(String.at(head, position) === "1", do: 1, else: 0))
  end

  def get_rating(data, flip_common_bit, position \\ 0)

  def get_rating(data, flip_common_bit, position) do
    bit_length = Enum.count(data)
    high_bits = get_high_bit_count(data, position)
    low_bits = bit_length - high_bits

    target_bit =
      cond do
        high_bits > low_bits -> bxor(1, flip_common_bit)
        high_bits < low_bits -> bxor(0, flip_common_bit)
        high_bits === low_bits -> bxor(1, flip_common_bit)
      end

    filtered_data =
      Enum.flat_map(data, fn number ->
        bit = String.at(number, position)
        {bit_int, ""} = Integer.parse(bit)
        if bit_int === target_bit, do: [number], else: []
      end)

    cond do
      Enum.count(filtered_data) === 1 -> Enum.at(filtered_data, 0)
      true -> get_rating(filtered_data, flip_common_bit, position + 1)
    end
  end

  def get_high_bit_frequency(data, half_length, frequency \\ %{})

  def get_high_bit_frequency([], _, frequency), do: frequency

  def get_high_bit_frequency([head | tail], half_length, frequency) do
    updated_frequency =
      head
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(frequency, fn {bit, index}, bit_frequency ->
        count = Map.get(bit_frequency, index, 0)
        Map.put(bit_frequency, index, if(bit === "1", do: count + 1, else: count))
      end)

    get_high_bit_frequency(tail, half_length, updated_frequency)
  end

  def run do
    data = get_input()
    IO.puts('Part one: #{part_one(data)}')
    IO.puts('Part two: #{part_two(data)}')
  end
end

DayThree.run()
