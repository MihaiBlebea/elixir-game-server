defmodule GameServer.SocketHandlerBase do

    defmacro __using__(_args) do
        quote do
            @behaviour :cowboy_websocket

            require Logger

            def init(request, _state) do
                {:cowboy_websocket, request, %{client_id: GameServer.Client.create_id}}
            end

            @spec websocket_init(map) :: {:ok, map} | {:reply, {:close, 1000, binary}, map}
            def websocket_init(state) do
                {:ok, state}
            end

            @spec websocket_handle({:text, binary}, any) :: {:reply, {:text, any}, any}
            def websocket_handle({:text, json}, state) do
                resp =
                    Poison.decode!(json)
                    |> to_atoms
                    |> validate_payload
                    |> add_client_id(state.client_id)
                    |> log
                    |> handler
                    |> handle_response
                    |> log

                {:reply, {:text, resp}, state}
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

            defp send_to_clients(response, clients) when is_list(clients) do
                clients
                |> Enum.map(fn (pid)->
                    if pid != self() do
                        Process.send(pid, response, [])
                    end
                end)
            end

            defp handle_response([:sender, payload]) do
                payload |> Poison.encode!
            end

            defp handle_response([clients, payload]) do
                response = payload |> Poison.encode!

                send_to_clients response, clients

                response
            end

            defp add_client_id(payload, client_id), do: Map.put(payload, :client_id, client_id)

            # defp close_connection(state, ), do: {:reply, {:close, 1000, "reason"}, state}
        end
    end
end
