defmodule GameServer.Client do

    @registry_key :client_registry

    def get_registry_key(), do: @registry_key

    @spec register(binary) :: :fail | :ok
    def register(game_id) do
        case Registry.register(@registry_key, game_id, []) do
            {:ok, _pid} -> :ok
            {:error, {:already_registered, _pid}} -> :fail
        end
    end

    @spec dispatch(binary, map) :: :ok
    def dispatch(game_id, response) do
        Registry.dispatch(@registry_key, game_id, fn (entries)->
            for {pid, _listener} <- entries, do: Process.send(pid, response, [])
        end)
    end

    def lookup(game_id) do
        Registry.lookup(@registry_key, game_id)
    end
end
