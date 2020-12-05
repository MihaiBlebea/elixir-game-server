defmodule GameServer.SnakeGame do

    use GameServer.Game

    alias GameServer.Snake

    def init(), do: %{created_by: "Mihai Blebea"}

    @spec game_loop(binary) :: none
    def game_loop(game_id) do

        game_id |> move_players

        state = game_id |> get_state

        game_id |> broadcast(state)

        :timer.sleep 500

        game_loop(game_id)
    end

    defp move_players(game_id) do
        game_id
        |> get_players
        |> Enum.map(fn (player_id)->
            Snake.move player_id
        end)
    end

    defp did_snakes_collide?(game_id) do
        game_id
        |> get_players
        |> Enum.map(fn (player_id)->
            Snake.get_body player_id
        end)
        |> cond do
            true -> false
        end
    end
end
