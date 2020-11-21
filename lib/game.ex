defmodule GameServer.Game do
    use Agent

    defstruct id: nil, board: nil, players: nil

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

    @spec lookup(binary) :: any
    def lookup(game_id) do
        Registry.lookup(:game_registry, game_id) |> Enum.at(0, nil) |> extract_pid
    end

    defp extract_pid({pid, nil}), do: pid
end
