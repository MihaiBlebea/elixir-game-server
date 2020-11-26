defmodule GameServer.SocketHandlerBase do

    defmacro __using__(_args) do
        quote do
            @behaviour :cowboy_websocket

            require Logger

            def init(request, state) do
                IO.inspect request
                {:cowboy_websocket, request, state}
            end

            @spec websocket_init(map) :: {:ok, map} | {:reply, {:close, 1000, binary}, map}
            def websocket_init(state) do
                {:ok, state}
            end

            @spec websocket_handle({:text, binary}, any) :: {:reply, {:text, any}, any}
            def websocket_handle({:text, json}, state) do
                resp =
                    Poison.decode!(json)
                    |> log
                    |> handle_event_type
                    |> log

                {:reply, {:text, resp}, state}
            end

            @spec websocket_info(any, any) :: {:reply, {:text, any}, any}
            def websocket_info(info, state) do
                {:reply, {:text, info}, state}
            end

            defp get_game_id_from_request(request), do: request.path_info |> Enum.at(0, nil)

            defp add_game_id_to_state(game_id), do: %{game_id: game_id}

            defp log(payload) when is_map(payload) do
                payload |> inspect |> Logger.debug

                payload
            end

            defp log(payload) when is_binary(payload) do
                payload |> Poison.decode! |> inspect |> Logger.debug

                payload
            end

            # defp close_connection(state), do: {:reply, {:close, 1000, "reason"}, state}
        end
    end
end
