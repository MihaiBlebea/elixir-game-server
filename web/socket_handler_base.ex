defmodule GameServer.SocketHandlerBase do

    defmacro __using__(_args) do
        quote do
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

            @spec websocket_info(any, any) :: {:reply, {:text, any}, any}
            def websocket_info(info, state) do
                {:reply, {:text, info}, state}
            end

            defp get_game_id_from_request(request), do: request.path_info |> Enum.at(0, nil)

            defp add_game_id_to_state(game_id), do: %{game_id: game_id}

            defp get_game_id_from_state(state), do: Map.get(state, :game_id, nil)

            defp close_connection(state), do: {:reply, {:close, 1000, "reason"}, state}
        end
    end
end
