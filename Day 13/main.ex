defmodule DayThirteen do
  @input_path "input"

  def get_input do
    {:ok, data} = File.read(@input_path)

    [points_str, instructions_str] =
      data
      |> String.trim()
      |> String.split("\r\n\r\n")

    points =
      points_str
      |> String.split("\r\n")
      |> Enum.map(fn point_token ->
        point_token
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)

    instructions =
      instructions_str
      |> String.split("\r\n")
      |> Enum.map(fn instruction_token ->
        %{"x" => x, "y" => y} = Regex.named_captures(~r/(?<=x=)(?<x>\d+)|(?<=y=)(?<y>\d+)/, instruction_token)

        cond do
          x !== "" -> %{:x => String.to_integer(x)}
          y !== "" -> %{:y => String.to_integer(y)}
        end
      end)

    [points: points, instructions: instructions, limits: get_page_limits(points)]
  end

  def part_one(data) do
    [points: points, instructions: instructions, limits: limits] = data;

    points
    |> fold(limits, hd(instructions))
    |> Enum.uniq()
    |> Enum.count()
  end

  def part_two(data) do
    [points: points, instructions: instructions, limits: limits] = data;

    folded_points = Enum.reduce(instructions, points, fn instruction, current_points ->
      Enum.uniq(fold(current_points, get_page_limits(current_points), instruction))
    end)

    "\n" <> render_page(folded_points, get_page_limits(folded_points))
  end

  def get_page_limits(points, limits \\ %{x: 0, y: 0})

  def get_page_limits([], limits), do: limits

  def get_page_limits([[x, y] | points], limits) do
    %{:x => limit_x, :y => limit_y} = limits

    limits =
      limits
      |> (fn map -> if x > Map.get(map, :x), do: %{map | x: x}, else: map end).()
      |> (fn map -> if y > Map.get(map, :y), do: %{map | y: y}, else: map end).()

    get_page_limits(points, limits)
  end

  def fold_by_x(points, %{:x => limit_x, :y => _}, fold_x) do
    {remaining_points, folded_points} = Enum.split_with(points, fn [x, _] -> x < fold_x end)

    folded_points
    |> Enum.map(fn [x, y] -> [limit_x - x, y] end)
    |> Kernel.++(remaining_points)
  end

  def fold_by_y(points, %{:x => _, :y => limit_y}, fold_y) do
    {remaining_points, folded_points} = Enum.split_with(points, fn [_, y] -> y < fold_y end)

    folded_points
    |> Enum.map(fn [x, y] -> [x, limit_y - y] end)
    |> Kernel.++(remaining_points)
  end

  def fold(points, limits, instruction) do
    cond do
      Map.has_key?(instruction, :x) -> fold_by_x(points, limits, Map.get(instruction, :x))
      Map.has_key?(instruction, :y) -> fold_by_y(points, limits, Map.get(instruction, :y))
    end
  end

  def render_page(points, %{:x => limit_x, :y => limit_y}) do
    screen_display = Enum.reduce(points, %{}, fn [x, y], screen_map ->
      Map.put(screen_map, [x, y], "#")
    end)

    for y <- 0..limit_y do
      0..limit_x
        |> Enum.map(&Map.get(screen_display, [&1, y], "."))
        |> Enum.join()
    end
    |> Enum.join("\n")
  end

  def run do
    data = get_input()
    IO.puts("Part one: #{part_one(data)}")
    IO.puts("Part two: #{part_two(data)}")
  end
end

DayThirteen.run()
