defmodule DayFifteen do
  Mix.install([:libgraph])
  @input_path "input"

  def get_input do
    {:ok, data} = File.read(@input_path)

    data
    |> String.trim()
    |> String.split("\r\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def part_one(data) do
    [v_start, v_end] = get_start_end_vertices(data)

    data
    |> create_graph()
    |> Graph.dijkstra(v_start, v_end)
    |> get_total_risk()
  end

  def part_two(data) do
    data_unwrapped =
      data
      |> unwrap_map_vertical()
      |> unwrap_map_horizontal()

    [v_start, v_end] = get_start_end_vertices(data_unwrapped)

    data_unwrapped
    |> create_graph()
    |> Graph.dijkstra(v_start, v_end)
    |> get_total_risk()
  end

  def get_map_size(vertices) do
    [length(Enum.at(vertices, 0)), length(vertices)]
  end

  def make_vertex(vertex, x, y) do
    %{:title => "#{vertex}.(#{x},#{y})", :risk => vertex}
  end

  def get_start_end_vertices(vertices_list) do
    [width, height] = get_map_size(vertices_list)
    v_start_raw = vertices_list |> Enum.at(0) |> Enum.at(0)
    v_end_raw = vertices_list |> Enum.at(height - 1) |> Enum.at(width - 1)
    v_start = make_vertex(v_start_raw, 0, 0)
    v_end = make_vertex(v_end_raw, width - 1, height - 1)
    [v_start, v_end]
  end

  def get_total_risk(path_vertices) do
    path_vertices
    |> tl()
    |> Enum.reduce(0, fn vertex, sum ->
      sum + Map.get(vertex, :risk)
    end)
  end

  def create_graph(vertices) do
    [width, height] = get_map_size(vertices)

    0..(height - 2)
    |> Enum.reduce(Graph.new(type: :directed, vertex_identifier: fn v -> v end), fn y, graph ->
      0..(width - 2)
      |> Enum.reduce(graph, fn x, graph_acc ->
        vc1 = vertices |> Enum.at(y) |> Enum.at(x)
        vc2 = vertices |> Enum.at(y) |> Enum.at(x + 1)
        vn1 = vertices |> Enum.at(y + 1) |> Enum.at(x)
        vn2 = vertices |> Enum.at(y + 1) |> Enum.at(x + 1)

        vc1_label = make_vertex(vc1, x, y)
        vc2_label = make_vertex(vc2, x + 1, y)
        vn1_label = make_vertex(vn1, x, y + 1)
        vn2_label = make_vertex(vn2, x + 1, y + 1)

        Graph.add_edges(
          graph_acc,
          [
            Graph.Edge.new(vc1_label, vc2_label, weight: vc2),
            Graph.Edge.new(vc2_label, vc1_label, weight: vc1),
            Graph.Edge.new(vn1_label, vn2_label, weight: vn2),
            Graph.Edge.new(vn2_label, vn1_label, weight: vn1),
            Graph.Edge.new(vc1_label, vn1_label, weight: vn1),
            Graph.Edge.new(vn1_label, vc1_label, weight: vc1),
            Graph.Edge.new(vc2_label, vn2_label, weight: vn2),
            Graph.Edge.new(vn2_label, vc2_label, weight: vc2)
          ]
        )
      end)
    end)
  end

  def unwrap_map_vertical(vertices_list) do
    [_, height] = get_map_size(vertices_list)

    Enum.reduce(0..3, vertices_list, fn (cell_index, vertices_list_acc) ->
      {_, right} = Enum.split(vertices_list_acc, cell_index * height)
      vertices_list_acc ++ Enum.map(right, fn (row) -> increase_risk_row(row) end)
    end)
  end

  def unwrap_map_horizontal(vertices_list) do
    [width, height] = get_map_size(vertices_list)

    Enum.map(0..(height - 1), fn (row_index) ->
      row = Enum.at(vertices_list, row_index)

      Enum.reduce(0..3, row, fn (cell_index, row_acc) ->
        {_, right} = Enum.split(row_acc, cell_index * width)
        row_acc ++ increase_risk_row(right)
      end)
    end)
  end

  def increase_risk_row(list) do
    Enum.map(list, fn (risk_level) -> rem(risk_level, 9) + 1 end)
  end

  def run do
    data = get_input()
    IO.puts("Part one: #{part_one(data)}")
    IO.puts("Part two: #{part_two(data)}")
  end
end

DayFifteen.run()
