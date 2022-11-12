defmodule Cave do
  @enforce_keys [:name, :is_small, :max_visits]
  defstruct [:name, :is_small, times_visited: 0, max_visits: :inifinity]
end

defmodule DayTwelve do
  @input_path "input"
  @initial_cave %Cave{name: "start", is_small: true, times_visited: 0, max_visits: 1}

  def get_input do
    Mix.install([:libgraph])
    {:ok, data} = File.read(@input_path)

    data
    |> String.trim()
    |> String.split("\r\n")
    |> Enum.map(&(String.split(&1, "-")))
    |> Enum.reduce(Graph.new([type: :directed]), fn ([start_name, end_name], graph) ->
      Graph.add_edges(graph, [{
        create_cave_vertex(start_name),
        create_cave_vertex(end_name)
      }])
    end)
  end

  def part_one(data) do
    traverse_paths(data, @initial_cave) |> flatten_paths() |> Enum.count()
  end

  def part_two(data) do
    get_small_caves(data)
    |> Enum.reduce([], fn small_cave_vertex, paths ->
      Graph.replace_vertex(data, small_cave_vertex, %{small_cave_vertex | max_visits: 2})
      |> traverse_paths(@initial_cave)
      |> flatten_paths()
      |> Enum.map(fn path -> Enum.map(path, fn vertex -> Map.get(vertex, :name) end) end)
      |> Kernel.++(paths)
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def traverse_paths(graph, vertex, paths \\ [])

  def traverse_paths(_, %{name: "end", is_small: true} = vertex, paths) do
    updated_vertex = %{vertex | times_visited: Map.get(vertex, :times_visited) + 1}
    [updated_vertex | paths]
  end

  def traverse_paths(graph, vertex, paths) do
    adjacent_vertices = Graph.neighbors(graph, vertex)
    updated_vertex = %{vertex | times_visited: Map.get(vertex, :times_visited) + 1}
    graph = Graph.replace_vertex(graph, vertex, updated_vertex)

    adjacent_vertices
    |> Enum.filter(fn next_vertex -> Map.get(next_vertex, :times_visited) < Map.get(next_vertex, :max_visits) end)
    |> Enum.map(fn next_vertex -> traverse_paths(graph, next_vertex, [updated_vertex | paths]) end)
    |> Enum.reject(&Enum.empty?/1)
  end

  def flatten_paths([]), do: []

  def flatten_paths([path | paths]) do
    cond do
      Enum.count(path) === 0 -> []
      path |> hd |> is_struct() -> [path] ++ flatten_paths(paths)
      true -> flatten_paths(path) ++ flatten_paths(paths)
    end
  end

  def get_small_caves(graph) do
    graph
    |> Graph.vertices()
    |> Enum.filter(fn %{:name => name, :is_small => is_small} ->
      is_small and not Enum.member?(["start", "end"], name)
    end)
  end

  def create_cave_vertex(name) do
    is_small = String.upcase(name) !== name
    max_visits = cond do
      is_small -> 1
      true -> :infinity
    end

    %Cave{
      name: name,
      is_small: is_small,
      max_visits: max_visits
    }
  end

  def run do
    data = get_input()
    IO.puts("Part one: #{part_one(data)}")
    IO.puts("Part two: #{part_two(data)}")
  end
end

DayTwelve.run()
