defmodule GameServer.Entity do

    @spec new(atom) :: atom
    def new(:concrete_wall), do: :concrete_wall

    def new(:brick_wall), do: :brick_wall

    def new(:door), do: :door

    def new(:enemy), do: :enemy

    def new(:player), do: :player
end
