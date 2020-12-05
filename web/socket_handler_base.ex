defmodule GameServer.SocketHandlerBase do

    @spec __using__(any) :: any
    defmacro __using__(_args) do
        quote do
            @behaviour :cowboy_websocket

            @timeout 60000

            require Logger

            def init(request, state) do
                {:cowboy_websocket, request, state}
            end

            @spec websocket_init(map) :: {:ok, map} | {:reply, {:close, 1000, binary}, map}
            def websocket_init(state) do
                {:ok, state}
            end

            @spec websocket_handle({:text, binary}, any) :: {:reply, {:text, any}, any}
            def websocket_handle({:text, json}, state) do
                Poison.decode!(json)
                |> to_atoms
                |> validate_payload
                |> log
                |> handler
                |> handle_response(state)
            end

            @spec websocket_info(any, any) :: {:reply, {:text, any}, any}
            def websocket_info(info, state) do
                {:reply, {:text, info}, state}
            end

            defp log(payload) when is_map(payload) do
                payload |> inspect |> Logger.debug

                payload
            end

            defp log(payload) when is_binary(payload) do
                payload |> Poison.decode! |> inspect |> Logger.debug

                payload
            end

            def to_atoms(map), do: for {key, val} <- map, into: %{}, do: { String.to_atom(key), val }

            def validate_payload(payload) when is_map(payload) do
                case Map.get(payload, :type, nil) do
                    nil -> :fail
                    val -> Map.put(payload, :type, String.to_atom(val))
                end
            end

            defp handle_response([:sender, payload], state) do
                response = payload |> Poison.encode!

                {:reply, {:text, response}, state}
            end

            defp handle_response([game_id, payload], state) do
                response = payload |> Poison.encode!

                GameServer.Client.dispatch(game_id, response)

                {:ok, state}
            end

            defp handle_response(nil, state), do: {:ok, state}

            defp broadcast(game_id, payload) do
                response = payload |> Poison.encode!

                GameServer.Client.dispatch(game_id, response)
            end

            def terminate(), do: :ok
            # defp close_connection(state, ), do: {:reply, {:close, 1000, "reason"}, state}
        end
    end
end
