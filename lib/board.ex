defmodule GameServer.Board do

    @behaviour GameServer.IDefineBoard

    alias GameServer.Box

    alias GameServer.Entity

    @moduledoc """
    This module creates and updates the board of the game. It acts as an aggregate to lower level entities like player, walls, bombs, etc.
    It can generate a board by calling the method build and providing a parameter size as integer.

    ```
    board = GameServer.Board.build(21)
    ```
    """
    @spec build(number) :: map
    def build(size) do
        cond do
            rem(size, 2) == 0 -> :even_size_fail
            size < 11 -> :small_size_fail
            true -> build(size, 0, 0, %{}) |> build_level
        end
    end

    @spec build(number, number, number, map) :: map
    defp build(size, x, y, result) do

        box = add_box(result, x, y)
        cond do
            x == size -> result
            y == size - 1 -> build(size, x + 1, 0, box)
            true -> build(size, x, y + 1, box)
        end
    end

    @spec build_level(map) :: map
    def build_level(board) do
        board
        |> build_concrete_walls
        |> build_brick_walls
        |> build_enemies
        # |> add_player
    end

    @doc """
    ### add_player
    Adds a player entity to the board. Returns the board map.
    ```
    GameServer.Board.add_player(board)
    ```
    """
    @spec add_player(map) :: map
    def add_player(board) do
        empty_boxes = get_empty_boxes board
        index = length(empty_boxes) - 1 |> :rand.uniform
        %{x: x, y: y} = empty_boxes |> Enum.at(index)

        add_entity(board, x, y, :player)
    end

    defp build_concrete_walls(board) do
        size = length(Map.values(board))

        for x <- 0..(size - 1), y <- 0..(size - 1) do
            cond do
                x == 0 || y == 0 || x == (size - 1) || y == (size - 1) -> %{x: x, y: y, entity: :concrete_wall}
                rem(x, 2) == 0 && rem(y, 2) == 0 -> %{x: x, y: y, entity: :concrete_wall}
                true -> nil
            end
        end
        |> List.flatten
        |> Enum.filter(fn (pos)-> pos !== nil end)
        |> Enum.reduce(board, fn (pos, board)-> add_entity(board, pos.x, pos.y, pos.entity) end)
    end

    defp build_brick_walls(board) do
        empty_boxes = get_empty_boxes board
        brick_count = length(empty_boxes) / 2 |> round

        build_brick_walls(board, empty_boxes, brick_count)
    end

    defp build_brick_walls(board, empty_boxes, brick_count) do
        case brick_count do
            0 -> board
            _count ->
                index = length(empty_boxes) - 1 |> :rand.uniform
                %{x: x, y: y} = empty_boxes |> Enum.at(index)
                case brick_count == 1 do
                    true -> board |> add_entity(x, y, :brick_wall) |> add_entity(x, y, :door)
                    false -> add_entity(board, x, y, :brick_wall)
                end
                |> build_brick_walls(
                    List.delete_at(empty_boxes, index),
                    brick_count - 1
                )
        end
    end

    defp build_enemies(board) do
        empty_boxes = get_empty_boxes board

        build_enemies board, empty_boxes, 3
    end

    defp build_enemies(board, empty_boxes, enemies_count) do
        case enemies_count do
            0 -> board
            _count ->
                index = length(empty_boxes) - 1 |> :rand.uniform
                %{x: x, y: y} = empty_boxes |> Enum.at(index)

                add_entity(board, x, y, :enemy)
                |> build_enemies(
                    List.delete_at(empty_boxes, index),
                    enemies_count - 1
                )
        end
    end

    @spec get_empty_boxes(map) :: [map]
    def get_empty_boxes(board) do
        size = length(Map.values(board))

        for x <- 0..(size - 1), y <- 0..(size - 1) do
            is_empty =
                board
                |> get_box(x, y)
                |> Box.is_empty?

            case is_empty do
                true -> %{x: x, y: y}
                false -> nil
            end
        end
        |> List.flatten
        |> Enum.filter(fn (pos)-> pos !== nil end)
    end

    @spec get_box(map, number, number) :: map | nil
    def get_box(board, x, y) do
        board
        |> Map.get(x)
        |> case do
            nil -> nil
            row -> Map.get(row, y, nil)
        end
    end

    # defp get_row(board, x) do
    #     board |> Map.get(x)
    # end

    defp add_box(board, x, y) do
        row = board |> Map.get(x, %{}) |> Map.put(y, %{entities: []})
        board |> Map.put(x, row)
    end

    defp add_box(board, x, y, box) do
        row = board |> Map.get(x, %{}) |> Map.put(y, box)
        board |> Map.put(x, row)
    end

    @spec add_entity(map, number, number, atom) :: map
    def add_entity(board, x, y, entity) do
        box = get_box(board, x, y) |> Box.add(Entity.new(entity))

        add_box(board, x, y, box)
    end
end
