defmodule GameServer.Player do

    @spec __using__(any) :: any
    defmacro __using__(_args) do

        quote do
            @behaviour GameServer.IDefinePlayer

            defstruct id: nil, client_pid: nil, name: nil, score: 0

            use GameServer.ActorBase, registry_name: :player_registry

            @spec put_name(binary, binary) :: :fail | :ok
            def put_name(player_id, name), do: put player_id, :name, name

            @spec put_client_pid(binary, pid) :: :fail | :ok
            def put_client_pid(player_id, client_pid), do: put player_id, :client_pid, client_pid

            @spec get_name(binary) :: binary
            def get_name(player_id), do: get player_id, :name

            @spec get_client_pid(binary) :: binary
            def get_client_pid(player_id), do: get player_id, :client_pid

            @spec new(binary, pid) :: binary
            def new(name, client_pid) when is_binary(name) and is_pid(client_pid) do
                id = start_link()
                id |> put_name(name)
                id |> put_client_pid(client_pid)
                id |> put_optional_params

                id
            end

            defp put_optional_params(player_id) do
                for {key, value} <- init(), do:  put player_id, key, value
            end
        end
    end
end
