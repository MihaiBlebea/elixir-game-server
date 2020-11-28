defmodule GameServer.Game do

    alias GameServer.Board

    alias GameServer.Player

    defstruct id: nil, name: nil, board: nil, players_count: nil, players: []

    use GameServer.ActorBase, registry_name: :game_registry

    @spec generate_board(binary) :: :fail | :ok
    def generate_board(game_id) do
        board = Board.build(21)

        put_board(game_id, board)
    end

    @spec get_players(binary) :: [pid]
    def get_players(game_id), do: get game_id, :players

    @spec get_players_client_pids(binary) :: [pid]
    def get_players_client_pids(game_id) do
        get_players(game_id)
        |> Enum.map(fn (player_id)-> Player.get_client_pid(player_id) end)
    end

    @spec get_board(binary) :: map
    def get_board(game_id), do: get game_id, :board

    @spec get_players_count(binary) :: number
    def get_players_count(game_id), do: get game_id, :players_count

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
    def put_board(game_id, value), do: put game_id, :board, value

    @spec put_name(binary, binary) :: :fail | :ok
    def put_name(game_id, name), do: put game_id, :name, name

    @spec put_players_count(binary, any) :: :fail | :ok
    def put_players_count(game_id, value), do: put game_id, :players_count, value

    @spec player_spaces_left(binary) :: number
    def player_spaces_left(game_id) do
        max_players_count = get game_id, :players_count
        players_count = get(game_id, :players) |> length

        max_players_count - players_count
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

    @spec run_game_loop(binary) :: no_return
    def run_game_loop(game_id) do
        board = get_board(game_id)

        resp = %{ type: :game_updated, board: board } |> Poison.encode!

        get_players_client_pids(game_id) |> Enum.map(fn (pid)-> Process.send(pid, resp, []) end)

        :timer.sleep 500

        run_game_loop(game_id)
    end
end
