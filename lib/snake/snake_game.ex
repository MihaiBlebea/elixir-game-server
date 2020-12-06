defmodule GameServer.SnakeGame do

    use GameServer.Game

    alias GameServer.Snake

    @spec init :: map
    def init(), do: %{created_by: "Mihai Blebea", power_ups: []}

    @spec game_loop(binary) :: nil | none
    def game_loop(game_id) do

        case has_powerups? game_id do
            true -> nil
            false -> gen_power_up game_id
        end

        game_id |> move_players

        should_eat_food game_id

        case is_game_over? game_id do
            true -> nil
            false -> continue_game game_id
        end
    end

    defp move_players(game_id) do
        game_id
        |> get_players
        |> Enum.map(fn (player_id)->
            Snake.move player_id
        end)
    end

    defp is_game_over?(game_id) do
        bodies =
            game_id
            |> get_players
            |> Enum.map(fn (player_id)->
                Snake.get_body player_id
            end)

        level = get game_id, :level

        cond do
            have_snakes_collided? bodies -> true
            are_snakes_out_of_bounds? bodies, level -> true
            true -> false
        end
    end

    defp continue_game(game_id) do
        state = game_id |> get_state

        game_id |> broadcast(state)

        :timer.sleep 500

        game_loop(game_id)
    end

    defp have_snakes_collided?(bodies) do
        bodies |> List.flatten |> has_duplicates?
    end

    defp are_snakes_out_of_bounds?(bodies, level) do
        found =
            bodies
            |> List.flatten
            |> Enum.filter(fn (segment)->
                segment.x == -1 || segment.y == -1 || segment.x > level.x || segment.y > level.y
            end)

        length(found) > 0
    end

    defp has_duplicates?(list), do: Enum.uniq(list) != list

    defp has_powerups?(game_id) do
        game_id
        |> get(:power_ups)
        |> length
        |> case do
            0 -> false
            _ -> true
        end
    end

    defp should_eat_food(game_id) do
        power_ups = game_id |> get(:power_ups)

        game_id
        |> get_players
        |> Enum.map(fn (player_id)->
            head = player_id |> Snake.get_body |> Snake.get_head
            if Enum.member?(power_ups, head) do
                Snake.eat(player_id)
            end
        end)
    end

    defp gen_power_up(game_id) do
        level = game_id |> get(:level)

        powerup = GameServer.Powerup.new(level.x, level.y)

        game_id |> push(:power_ups, powerup)
    end
end
