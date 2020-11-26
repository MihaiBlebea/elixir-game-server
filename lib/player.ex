defmodule GameServer.Player do

    use Agent

    defstruct id: nil, name: nil

    @spec start_link :: binary
    def start_link() do
        id = UUID.uuid4()
        name = {:via, Registry, {:player_registry, id}}

        case Agent.start_link(fn ()-> %__MODULE__{id: id} end, name: name) do
            {:error, {:already_started, _pid}} -> id
            {:ok, _pid} -> id
        end
    end

    defp lookup(player_id) do
        Registry.lookup(:player_registry, player_id) |> Enum.at(0, nil) |> extract_pid
    end

    defp extract_pid({pid, nil}), do: pid

    defp extract_pid(nil), do: nil

    defp get(player_id, key) when is_binary(player_id) do
        case lookup(player_id) do
            nil -> nil
            pid -> pid |> Agent.get(fn (state)-> Map.get(state, key) end)
        end
    end

    @spec put_name(binary, binary) :: :fail | :ok
    def put_name(player_id, name) do
        case lookup(player_id) do
            nil -> :fail
            pid -> Agent.update(pid, fn (state)-> Map.put(state, :name, name) end)
        end
    end

    @spec get_name(binary) :: binary
    def get_name(player_id), do: get(player_id, :name)
end
