defmodule GameServer.SocketHandler do

    use GameServer.SocketHandlerBase

    alias GameServer.Game

    alias GameServer.Player

    defp handler(%{type: :game_create, player_count: players_count, game_name: game_name}) do
        game_id = Game.new(game_name, players_count)

        [:sender, %{ type: :game_created, game_id: game_id, max_players: players_count }]
    end

    defp handler(%{type: :game_join, game_id: game_id, client_id: _client_id, player_name: player_name}) do
        player_id = player_name |> Player.new(self())
        case Game.put_player(game_id, player_id) do
            :fail -> [:sender, %{ type: :game_error, message: "could not add player to the game" }]
            spaces -> game_has_spaces_left spaces, game_id
        end
    end

    defp handler(%{type: :level_start, game_id: game_id}) do
        spawn fn ()->
            Game.get_board(game_id)
        end
    end

    defp handler(%{type: :player_move, game_id: game_id, x: x, y: y, move_x: move_x}) do
        clients = Game.get_players_client_pids(game_id)
        [clients, %{ type: :player_moved, x: x, y: y, move_x: move_x}]
    end

    defp handler(%{type: :player_move, game_id: game_id, x: x, y: y, move_y: move_y}) do
        clients = Game.get_players_client_pids(game_id)
        [clients, %{ type: :player_moved, x: x, y: y, move_y: move_y}]
    end

    defp handler(_) do
        [:sender, %{type: :game_error, message: "invalid request"}]
    end

    defp game_has_spaces_left(0, game_id) do
        spawn fn ()->
            :timer.sleep 5000

            Game.run_game_loop(game_id)
        end

        clients = Game.get_players_client_pids(game_id)
        [clients, %{ type: :game_joined, spaces_left: 0, game_id: game_id}]
    end

    defp game_has_spaces_left(spaces, game_id) do
        clients = Game.get_players_client_pids(game_id)
        [clients, %{ type: :game_joined, spaces_left: spaces, game_id: game_id}]
    end
end
