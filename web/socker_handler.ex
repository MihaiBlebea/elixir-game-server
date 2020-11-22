defmodule GameServer.SocketHandler do
    @behaviour :cowboy_websocket

    def init(request, _state) do

        IO.inspect request
        state = %{registry_key: request.path}
        {:cowboy_websocket, request, state}
    end

    @spec websocket_init(atom | %{registry_key: any}) :: {:ok, atom | %{registry_key: any}}
    def websocket_init(state) do
        IO.inspect state
        IO.inspect "SOCKET INIT"
        :socket_conn_registry |> Registry.register(state.registry_key, {})

        {:ok, state}
    end

    @spec websocket_handle({:text, binary}, any) :: {:reply, {:text, any}, any}
    def websocket_handle({:text, json}, state) do
        payload = Poison.decode!(json)
        response = payload["data"] |> handle_type

        # message = payload["data"]["message"]
        # IO.inspect payload
        :socket_conn_registry
        |> Registry.dispatch(state.registry_key, fn(entries) ->
            for {pid, _} <- entries do
                if pid != self() do
                    Process.send(pid, Poison.encode!(response), [])
                end
            end
        end)

        {:reply, {:text, Poison.encode!(response)}, state}
    end

    @spec websocket_info(any, any) :: {:reply, {:text, any}, any}
    def websocket_info(info, state) do
        {:reply, {:text, info}, state}
    end

    # def handle_type(%{"type" => "game_create"}) do
    #     game_id = GameServer.Game.start_link()
    #     board = GameServer.Game.get(game_id, :board)

    #     JSON.encode!(%{
    #         type: "game_created",
    #         game_id: game_id,
    #         board: board
    #     })
    # end

    defp handle_type(%{"type" => "game_join", "code" => game_id}) do
        board = GameServer.Game.get(game_id, :board)

        # Poison.encode!(%{
        #     type: "game_joined",
        #     game_id: game_id,
        #     board: board
        # })

        %{
            type: "game_joined",
            game_id: game_id,
            board: board
        }
    end
end
