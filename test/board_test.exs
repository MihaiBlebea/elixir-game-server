defmodule BoardTest do
    use ExUnit.Case

    defp get_wall_positions(board_size) do
        for x <- 0..(board_size - 1), y <- 0..(board_size - 1) do
            cond do
                x == 0 || y == 0 || x == (board_size - 1) || y == (board_size - 1) -> %{x: x, y: y}
                rem(x, 2) == 0 && rem(y, 2) == 0 -> %{x: x, y: y}
                true -> nil
            end
        end
        |> List.flatten
        |> Enum.filter(fn (pos)-> pos !== nil end)
    end

    test "can build a board of a defined size" do
        board = GameServer.Board.build 21

        assert board |> Map.values |> length == 21
    end

    test "can not create board of even size" do
        board = GameServer.Board.build 12

        assert board == :even_size_fail
    end

    test "can not create board with size smaller then 11" do
        board = GameServer.Board.build 5

        assert board == :small_size_fail
    end

    test "board has concrete walls around the margins and in the middle" do
        board_size = 11
        board = GameServer.Board.build board_size

        for pos <- get_wall_positions(board_size) do
            box = board |> Map.get(pos.x) |> Map.get(pos.y)
            assert GameServer.Box.get_top(box) == :concrete_wall
        end
    end
end
