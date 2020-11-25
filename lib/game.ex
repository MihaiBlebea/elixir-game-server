defmodule GameServer.Game do
    use Agent

    defstruct id: nil, board: nil, players_count: nil, players: []

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
        board = GameServer.Board.build(21)

        put_board(game_id, board)
    end

    @doc """
    Creates the game loop.
    Put this in a different prcess and it will infinite loop,
    sending updates of the board to all the registered players
    """
    # @spec run_game_loop(any) :: none
    # def run_game_loop(game_id) do
    #     board = get(game_id, :board)

    #     resp = %{ type: "game_updated", board: board } |> Poison.encode!

    #     get(game_id, :players) |> Enum.map(fn (pid)-> Process.send(pid, resp, []) end)

    #     :timer.sleep 500

    #     run_game_loop(game_id)
    # end

    @spec lookup(binary) :: pid | nil
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

    @spec get_board(binary) :: map
    def get_board(game_id), do: get(game_id, :board)

    @spec get_players_count(binary) :: number
    def get_players_count(game_id), do: get(game_id, :players_count)

    @spec put_player(binary, any) :: :ok | :fail
    def put_player(game_id, value) do
        case lookup(game_id) do
            nil -> :fail
            pid ->
                # Adds a new player to the board
                board = get_board(game_id) |> GameServer.Board.add_player
                put_board(game_id, board)
                Agent.update(pid, fn (state)-> Map.put(state, :players, state.players ++ [value]) end)
        end
    end

    @spec put_board(binary, map) :: :fail | :ok
    def put_board(game_id, value) do
        case lookup(game_id) do
            nil -> :fail
            pid -> Agent.update(pid, fn (state)-> Map.put(state, :board, value) end)
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
end
