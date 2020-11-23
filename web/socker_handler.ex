defmodule GameServer.SocketHandler do
    @behaviour :cowboy_websocket

    def init(request, _state) do
        state = request |> get_game_id_from_request |> add_game_id_to_state
        {:cowboy_websocket, request, state}
    end

    @spec websocket_init(map) :: {:ok, map} | {:reply, {:close, 1000, binary}, map}
    def websocket_init(state) do
        case Map.get(state, :game_id, nil) do
            nil -> close_connection state
            game_id ->
                GameServer.Game.put_player(game_id, self())
                {:ok, state}
        end
    end

    @spec websocket_handle({:text, binary}, any) :: {:reply, {:text, any}, any}
    def websocket_handle({:text, json}, state) do
        resp =
            Poison.decode!(json)
            |> handle_event_type(get_game_id_from_state(state))

        {:reply, {:text, resp}, state}
    end

    @spec websocket_info(any, any) :: {:reply, {:text, any}, any}
    def websocket_info(info, state) do
        {:reply, {:text, info}, state}
    end

    defp handle_event_type(%{"type" => "game_join"}, game_id) do
        board = GameServer.Game.get(game_id, :board)

        %{ type: "game_joined", board: board } |> Poison.encode!
    end

    defp handle_event_type(%{"type" => "game_move"}, game_id) do
        # board = GameServer.Game.get(game_id, :board)
        resp = %{ type: "game_moved" } |> Poison.encode!

        GameServer.Game.get(game_id, :players)
        |> IO.inspect
        |> Enum.map(fn (pid)->
            if pid != self() do
                Process.send(pid, resp, [])
            end
        end)

        resp
    end

    defp get_game_id_from_request(request), do: request.path_info |> Enum.at(0, nil)

    defp add_game_id_to_state(game_id), do: %{game_id: game_id}

    defp get_game_id_from_state(state), do: Map.get(state, :game_id, nil)

    defp close_connection(state), do: {:reply, {:close, 1000, "reason"}, state}
end
