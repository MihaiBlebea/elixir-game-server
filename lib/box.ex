defmodule GameServer.Box do

    @spec add(atom) :: map
    def add(entity) when is_atom(entity) do
        %{entities: [entity]}
    end

    @spec add(map, atom) :: map
    def add(%{entities: entities}, entity) when is_atom(entity) do
        %{entities: entities ++ [entity]}
    end

    @spec is_empty?(map) :: boolean
    def is_empty?(%{entities: entities}), do: length(entities) == 0

    @spec get_top(map) :: atom
    def get_top(%{entities: entities}), do: List.first entities
end
