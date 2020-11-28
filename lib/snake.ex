defmodule GameServer.Snake do

    defstruct player_id: nil, player_name: nil, body: [], head_direction: :left

    @spec new(binary, binary) :: %GameServer.Snake{}
    def new(player_id, player_name) do
        %__MODULE__{player_id: player_id, player_name: player_name}
    end

    def move(%GameServer.Snake{} = snake) do

    end


end
