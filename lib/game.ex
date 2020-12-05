defmodule GameServer.Game do

    defstruct id: nil, name: nil, level: %{}, max_players: nil, players: []

    use GameServer.ActorBase, registry_name: :game_registry

    alias GameServer.Player

    @spec __using__(any) :: any
    defmacro __using__(_args) do

        quote do

            defstruct id: nil, name: nil, level: %{}, max_players: nil, players: []

            use GameServer.ActorBase, registry_name: :game_registry

            alias GameServer.Client

            @spec get_players(binary) :: [pid]
            def get_players(game_id), do: get game_id, :players

            @spec get_max_players(binary) :: number
            def get_max_players(game_id), do: get game_id, :max_players

            def get_state(game_id), do: GameServer.Game.get_state(game_id)
            #     state = get_all game_id

            #     players =
            #         state.players
            #         |> Enum.map(fn (player_id)->
            #             get_player_module().get_all(player_id)
            #         end)

            #     Map.put(:players, players)
            # end

            @spec put_player(binary, binary) :: :fail | integer
            def put_player(game_id, player_id) do
                already_joined =
                    get_current_joined_player(game_id)
                    |> Enum.filter(fn (pid)->
                        pid == self()
                    end)
                    |> length
                    |> already_joined?

                cond do
                    already_joined -> :fail
                    no_spaces_left? get_current_joined_player(game_id) |> length, get_max_players(game_id) -> :fail
                    true ->
                        GameServer.Client.register(game_id)
                        push(game_id, :players, player_id)
                        player_spaces_empty(get_current_joined_player(game_id) |> length, get_max_players(game_id))
                end
            end

            @spec put_name(binary, binary) :: :fail | :ok
            def put_name(game_id, name), do: put game_id, :name, name

            @spec put_max_players(binary, any) :: :fail | :ok
            def put_max_players(game_id, value), do: put game_id, :max_players, value

            @spec new(binary, number) :: binary
            def new(name, players_count) do
                id = start_link()
                id |> put_name(name)
                id |> put_max_players(players_count)
                id |> put_optional_params

                id
            end

            defp already_joined?(0), do: false

            defp already_joined?(_), do: true

            defp no_spaces_left?(current, max_players), do: max_players == current

            defp player_spaces_empty(current, max_players), do: max_players - current

            defp get_current_joined_player(game_id) do
                GameServer.Client.lookup(game_id) |> Enum.map(fn ({pid, []})-> pid end)
            end

            def broadcast(game_id, response) do
                resp = response |> Map.delete(:client_pid) |> IO.inspect |> Poison.encode!
                Client.dispatch(game_id, resp)
            end

            defp put_optional_params(player_id) do
                for {key, value} <- init(), do:  put player_id, key, value
            end
        end
    end

    @spec get_state(binary) :: map
    def get_state(game_id) do
        state = get_all game_id

        players =
            state.players
            |> Enum.map(fn (player_id)->
                Player.get_all(player_id)
            end)

        state |> Map.put(:players, players)
    end
end
