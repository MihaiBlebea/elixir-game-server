defmodule GameServer.SnakeGame do

    def init() do
        %{board: %{}, players: [], powerups: []}
    end

    @spec game_loop(map) :: no_return
    def game_loop(state) when is_map(state) do

        IO.inspect state
        :timer.sleep 500

        game_loop(state)
    end

    @spec power_up :: %{powerup: any, x: pos_integer, y: pos_integer}
    def power_up() do
        powerups = [:apple, :grape, :diamond]

        %{
            x: random(3),
            y: random(3),
            powerup: powerups |> Enum.at(random(length(powerups)))
        }
    end

    defp random(max) do
        :rand.uniform(max)
    end
end
