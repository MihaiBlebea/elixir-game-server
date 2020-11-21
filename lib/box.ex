defmodule GameServer.Box do

    defstruct entities: []

    @spec add(atom) :: %GameServer.Box{}
    def add(entity) when is_atom(entity) do
        %GameServer.Box{entities: [entity]}
    end

    @spec add(%GameServer.Box{}, atom) :: %GameServer.Box{}
    def add(%GameServer.Box{entities: entities}, entity) when is_atom(entity) do
        %GameServer.Box{entities: entities ++ [entity]}
    end

    @spec is_empty?(%GameServer.Box{}) :: boolean
    def is_empty?(%GameServer.Box{entities: entities}), do: length(entities) == 0

    @spec get_top(%GameServer.Box{}) :: atom
    def get_top(%GameServer.Box{entities: entities}), do: List.first entities
end
