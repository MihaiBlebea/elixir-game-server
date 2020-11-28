defmodule SocketHandlerTest do
    use ExUnit.Case

    test "can build a board of a defined size" do
        board = GameServer.Board.build 21

        assert board |> Map.values |> length == 21
    end
end
