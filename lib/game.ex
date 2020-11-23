defmodule GameServer.Game do
    use Agent

    defstruct id: nil, board: nil, players: []

    @spec start_link :: binary
    def start_link() do
        id = UUID.uuid4()
        name = {:via, Registry, {:game_registry, id}}
        board = GameServer.Board.build(21)

        case Agent.start_link(fn ()-> %__MODULE__{id: id, board: board} end, name: name) do
            {:error, {:already_started, _pid}} -> id
            {:ok, _pid} -> id
        end
    end

    @spec lookup(binary) :: pid | nil
    def lookup(game_id) do
        Registry.lookup(:game_registry, game_id) |> Enum.at(0, nil) |> extract_pid
    end

    defp extract_pid({pid, nil}), do: pid

    defp extract_pid(nil), do: nil

    @spec get(binary, binary) :: any
    def get(game_id, key) when is_binary(game_id) do
        case lookup(game_id) do
            nil -> nil
            pid -> pid |> Agent.get(fn (state)-> Map.get(state, key) end)
        end
    end

    @spec put(binary, atom, any) :: :ok | :fail
    def put(game_id, key, value) when is_atom(key) do
        case lookup(game_id) do
            nil -> :fail
            pid -> Agent.update(pid, fn (state)-> Map.put(state, key, value) end)
        end
    end

    @spec put(binary, atom, any) :: :ok | :fail
    def put_player(game_id, value) do
        case lookup(game_id) do
            nil -> :fail
            pid -> Agent.update(pid, fn (state)-> Map.put(state, :players, state.players ++ [value]) end)
        end
    end
end
