defmodule GameServer.Player do

    use Agent

    defstruct id: nil, client_pid: nil, name: nil, score: 0

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

    @spec put_client_pid(binary, pid) :: :fail | :ok
    def put_client_pid(player_id, client_pid) do
        case lookup(player_id) do
            nil -> :fail
            pid -> Agent.update(pid, fn (state)-> Map.put(state, :client_pid, client_pid) end)
        end
    end

    @spec get_name(binary) :: binary
    def get_name(player_id), do: get(player_id, :name)

    @spec get_client_pid(binary) :: binary
    def get_client_pid(player_id), do: get(player_id, :client_pid)

    @spec new(binary, pid) :: binary
    def new(name, client_pid) when is_binary(name) and is_pid(client_pid) do
        id = start_link()
        id |> put_name(name)
        id |> put_client_pid(client_pid)

        id
    end
end
