defmodule GameServer.Powerup do

    @types [:apple, :grape, :diamond]

    defstruct type: nil, x: nil, y: nil

    @spec new(pos_integer, pos_integer) :: %GameServer.Powerup{}
    def new(max_x, max_y) do
        index = @types |> length |> random
        %__MODULE__{
            x: random(max_x),
            y: random(max_y),
            type: @types |> Enum.at(index)
        }
    end

    defp random(max) do
        :rand.uniform(max)
    end
end
