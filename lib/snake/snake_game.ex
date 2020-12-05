defmodule GameServer.SnakeGame do

    use GameServer.Game

    alias GameServer.Snake

    def init(), do: %{created_by: "Mihai Blebea"}

    @spec game_loop(binary) :: none
    def game_loop(game_id) do

        state = get_state game_id
        IO.inspect state
        :timer.sleep 500

        game_id |> broadcast(Poison.encode!(state))

        game_loop(game_id)
    end
    # alias GameServer.Powerup

    # defstruct status: nil, level: %{}, snakes: [], power_ups: []

    def event(_game_id, %{target: snake_id, move_x: -1, move_y: 0}) do
        Snake.move snake_id, -1, 0
    end

    # @spec game_loop(binary) :: none
    # def game_loop(game_id), do: game_loop(game_id, %GameServer.SnakeGame{})

    # @spec game_loop(binary, %GameServer.SnakeGame{}) :: none
    # def game_loop(game_id, %GameServer.SnakeGame{} = state) do

    #     IO.inspect state
    #     :timer.sleep 500

    #     encoded = state |> Poison.encode!
    #     GameServer.Client.dispatch(game_id, encoded)

    #     game_loop(game_id, state)
    # end
end
