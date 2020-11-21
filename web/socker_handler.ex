defmodule GameServer.SocketHandler do
    @behaviour :cowboy_websocket

    def init(request, _state) do
        state = %{registry_key: request.path}
        {:cowboy_websocket, request, state}
    end

    @spec websocket_init(atom | %{registry_key: any}) :: {:ok, atom | %{registry_key: any}}
    def websocket_init(state) do
        :socket_conn_registry |> Registry.register(state.registry_key, {})

        {:ok, state}
    end

    @spec websocket_handle({:text, bitstring | char_list}, any) :: {:reply, {:text, any}, any}
    def websocket_handle({:text, json}, state) do
        payload = JSON.decode!(json)
        response = payload["data"] |> handle_type

        # message = payload["data"]["message"]
        # IO.inspect payload
        :socket_conn_registry
        |> Registry.dispatch(state.registry_key, fn(entries) ->
            for {pid, _} <- entries do
                if pid != self() do
                    Process.send(pid, response, [])
                end
            end
        end)

        {:reply, {:text, response}, state}
    end

    def websocket_info(info, state) do
        {:reply, {:text, info}, state}
    end

    def handle_type(%{"type" => "game_create"}) do
        game_id = GameServer.Game.start_link()
        board = GameServer.Game.get(game_id, :board)

        JSON.encode!(%{
            game_id: game_id,
            board: board
        })
    end
end
