defmodule GameServer.Event.EventBase do

    @spec build(atom, map) :: %{type: atom}
    def build(:game_create, payload) when is_map(payload) do
        payload |> Map.put(:type, :game_created)
    end

    def build(:game_join, payload) when is_map(payload) do
        payload |> Map.put(:type, :game_joined)
    end

    def build(:game_start, payload) when is_map(payload) do
        payload |> Map.put(:type, :game_started)
    end

    def build(name, payload) when is_map(payload) and is_atom(name) do
        payload |> Map.put(:type, name)
    end
end
