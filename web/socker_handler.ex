defmodule GameServer.SocketHandler do

    use GameServer.SocketHandlerBase

    defp handler(%{type: :game_create, player_count: players_count, game_name: game_name}) do
        game_id = get_game_module().new(game_name, players_count)

        [:sender, %{ type: :game_created, game_id: game_id, max_players: players_count }]
    end

    defp handler(%{type: :game_join, game_id: game_id, player_name: player_name}) do
        player_id = player_name |> get_player_module().new(self())

        case get_game_module().put_player(game_id, player_id) do
            :fail -> [:sender, %{ type: :game_error, message: "could not add player to the game" }]
            spaces -> game_has_spaces_left spaces, game_id
        end
    end

    defp handler(%{type: :player_move, game_id: game_id, x: x, y: y, move_x: move_x}) do
        [game_id, %{ type: :player_moved, x: x, y: y, move_x: move_x}]
    end

    defp handler(%{type: :player_move, game_id: game_id, x: x, y: y, move_y: move_y}) do
        [game_id, %{ type: :player_moved, x: x, y: y, move_y: move_y}]
    end

    defp handler(_) do
        [:sender, %{type: :game_error, message: "invalid request"}]
    end

    defp game_has_spaces_left(0, game_id) do
        spawn fn ()->
            :timer.sleep 2000

            game_count_down game_id

            get_game_module().game_loop(game_id)
        end

        [game_id, %{ type: :game_joined, spaces_left: 0, game_id: game_id}]
    end

    defp game_has_spaces_left(spaces, game_id) do
        [game_id, %{ type: :game_joined, spaces_left: spaces, game_id: game_id}]
    end

    defp game_count_down(game_id) do
        max = 5
        Enum.map(0..max, fn (count)->
            broadcast(game_id, %{type: :game_starting, time_left: max - count, game_id: game_id})
            :timer.sleep 1000

            nil
        end)
    end

    defp get_game_module(), do: Application.get_env(:game_server, :game_module)

    defp get_player_module, do: Application.get_env(:game_server, :player_module)
end
