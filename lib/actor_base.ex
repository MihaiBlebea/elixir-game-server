defmodule GameServer.ActorBase do

    @spec __using__(any) :: any
    defmacro __using__(args) do

        [registry_name: registry_name] = args

        quote do
            use Agent

            @registry_name unquote(registry_name)

            @spec start_link :: binary
            def start_link() do
                id = UUID.uuid4()
                name = {:via, Registry, {@registry_name, id}}

                case Agent.start_link(fn ()-> %__MODULE__{id: id} end, name: name) do
                    {:error, {:already_started, _pid}} -> id
                    {:ok, _pid} -> id
                end
            end

            defp lookup(id) do
                Registry.lookup(@registry_name, id) |> Enum.at(0, nil) |> extract_pid
            end

            defp extract_pid({pid, nil}), do: pid

            defp extract_pid(nil), do: nil

            defp get(id, key) when is_binary(id) and is_atom(key) do
                case lookup(id) do
                    nil -> :fail
                    pid -> pid |> Agent.get(fn (state)-> Map.get(state, key) end)
                end
            end

            defp get_all(id) when is_binary(id) do
                case lookup(id) do
                    nil -> :fail
                    pid -> pid |> Agent.get(fn (state)-> state end)
                end
            end

            defp put(id, key, value) when is_binary(id) and is_atom(key) do
                case lookup(id) do
                    nil -> :fail
                    pid -> Agent.update(pid, fn (state)-> Map.put(state, key, value) end)
                end
            end

            defp push(id, key, value) when is_binary(id) and is_atom(key) do
                case lookup(id) do
                    nil -> :fail
                    pid -> Agent.update(pid, fn (state)->
                        list = Map.get(state, key)
                        Map.put(state, key, list ++ [value])
                    end)
                end
            end
        end
    end
end
