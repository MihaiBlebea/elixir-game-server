defmodule GameServer.SocketHandler do

    use GameServer.SocketHandlerBase

    alias GameServer.Game

    @spec websocket_handle({:text, binary}, any) :: {:reply, {:text, any}, any}
    def websocket_handle({:text, json}, state) do
        resp =
            Poison.decode!(json)
            |> handle_event_type(get_game_id_from_state(state))

        {:reply, {:text, resp}, state}
    end

    defp handle_event_type(%{"type" => "game_join"}, game_id) do
        board = Game.get(game_id, :board)

        %{ type: "game_joined", board: board } |> Poison.encode!
    end

    defp handle_event_type(%{"type" => "game_move", "direction" => direction}, game_id) do
        resp = %{ type: "game_moved", direction: direction } |> Poison.encode!

        Game.get(game_id, :players)
        |> Enum.map(fn (pid)->
            if pid != self() do
                Process.send(pid, resp, [])
            end
        end)

        resp
    end
end
