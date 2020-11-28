defmodule GameServer.Game do
    use Agent

    alias GameServer.Board

    alias GameServer.Player

    defstruct id: nil, name: nil, board: nil, players_count: nil, players: []

    @spec start_link :: binary
    def start_link() do
        id = UUID.uuid4()
        name = {:via, Registry, {:game_registry, id}}

        case Agent.start_link(fn ()-> %__MODULE__{id: id} end, name: name) do
            {:error, {:already_started, _pid}} -> id
            {:ok, _pid} -> id
        end
    end

    @spec generate_board(binary) :: :fail | :ok
    def generate_board(game_id) do
        board = Board.build(21)

        put_board(game_id, board)
    end

    defp lookup(game_id) do
        Registry.lookup(:game_registry, game_id) |> Enum.at(0, nil) |> extract_pid
    end

    defp extract_pid({pid, nil}), do: pid

    defp extract_pid(nil), do: nil

    defp get(game_id, key) when is_binary(game_id) do
        case lookup(game_id) do
            nil -> nil
            pid -> pid |> Agent.get(fn (state)-> Map.get(state, key) end)
        end
    end

    # defp put(game_id, key, value) when is_atom(key) do
    #     case lookup(game_id) do
    #         nil -> :fail
    #         pid -> Agent.update(pid, fn (state)-> Map.put(state, key, value) end)
    #     end
    # end

    @spec get_players(binary) :: [pid]
    def get_players(game_id), do: get(game_id, :players)

    @spec get_players_client_pids(binary) :: [pid]
    def get_players_client_pids(game_id) do
        get_players(game_id)
        |> Enum.map(fn (player_id)-> Player.get_client_pid(player_id)   end)
    end

    @spec get_board(binary) :: map
    def get_board(game_id), do: get(game_id, :board)

    @spec get_players_count(binary) :: number
    def get_players_count(game_id), do: get(game_id, :players_count)

    @doc """
    #### put_player/2

    Stores a new player by id in the game struct.

    Returns the remaining number of player spaces that are not taken yet in the game

    Returns `:fail` if an error occurs

    params:
    - game_id: an id to lookup the game in the game registry
    - player_id: an id to lookup the player in the player registry

    #### example:

        iex> GameServer.Game.put_player("da60eba5-2d93-4a8d-bcf0-b622152f82a8", "12345-2d93-4a8d-bcf0-b622152f82a8")
        2

    """
    @spec put_player(binary, binary) :: :fail | integer
    def put_player(game_id, player_id) do
        client_pid = Player.get_client_pid player_id
        case lookup(game_id) do
            nil -> :fail
            pid ->
                cond do
                    player_already_joined? game_id, client_pid -> :fail
                    player_spaces_left(game_id) == 0 -> :fail
                    true ->
                        Agent.update(pid, fn (state)-> Map.put(state, :players, state.players ++ [player_id]) end)
                        player_spaces_left game_id
                end
        end
    end

    @spec put_board(binary, map) :: :fail | :ok
    def put_board(game_id, value) do
        case lookup(game_id) do
            nil -> :fail
            pid -> Agent.update(pid, fn (state)-> Map.put(state, :board, value) end)
        end
    end

    @spec put_name(binary, binary) :: :fail | :ok
    def put_name(game_id, name) do
        case lookup(game_id) do
            nil -> :fail
            pid -> Agent.update(pid, fn (state)-> Map.put(state, :name, name) end)
        end
    end

    @spec put_players_count(binary, any) :: :fail | :ok
    def put_players_count(game_id, value) do
        case lookup(game_id) do
            nil -> :fail
            pid -> Agent.update(pid, fn (state)-> Map.put(state, :players_count, value) end)
        end
    end

    @spec player_spaces_left(binary) :: number
    def player_spaces_left(game_id) do
        case lookup(game_id) do
            nil -> :fail
            pid ->
                max_players_count = pid |> Agent.get(fn (state)-> Map.get(state, :players_count) end)
                players_count = pid |> Agent.get(fn (state)-> Map.get(state, :players) end) |> length

                max_players_count - players_count
        end
    end

    @spec new(binary, number) :: binary
    def new(name, players_count) do
        id = start_link()
        id |> generate_board
        id |> put_name(name)
        id |> put_players_count(players_count)

        id
    end

    defp player_already_joined?(game_id, client_pid) do
        case game_id |> get_players |> Enum.filter(fn (player_id)-> Player.get_client_pid(player_id) == client_pid end) |> length do
            0 -> false
            _ -> true
        end
    end
end
