defmodule GameServer.SocketHandler do

    use GameServer.SocketHandlerBase

    alias GameServer.Game

    alias GameServer.Player

    defp handler(%{type: :game_create, player_count: players_count, game_name: game_name}) do
        game_id = GameServer.Game.start_link
        GameServer.Game.generate_board game_id
        GameServer.Game.put_players_count game_id, players_count

        [:sender, %{ type: :game_created, game_id: game_id, max_players: players_count }]
    end

    defp handler(%{type: :game_join, game_id: game_id, client_id: client_id}) do
        case Game.player_spaces_left game_id do
            0 -> [:sender, %{ type: :game_error, message: "no spaces left" }]
            1 ->
                # Send the board and start the game
                # player_id = Player.start_link()

                Game.put_player(game_id, self())
                board = Game.get_board(game_id)
                [Game.get_players(game_id), %{ type: :game_joined, board: board, spaces_left: 0, game_id: game_id}]

            spaces_left ->
                Game.put_player(game_id, self())
                [Game.get_players(game_id), %{ type: :game_joined, spaces_left: spaces_left - 1, game_id: game_id}]
        end
    end

    defp handler(%{type: :player_move, game_id: game_id, x: x, y: y, move_x: move_x}) do
        [Game.get_players(game_id), %{ type: :player_moved, x: x, y: y, move_x: move_x}]
    end

    defp handler(%{type: :player_move, game_id: game_id, x: x, y: y, move_y: move_y}) do
        [Game.get_players(game_id), %{ type: :player_moved, x: x, y: y, move_y: move_y}]
    end

    defp handler(_) do
        [:sender, %{type: :game_error, message: "invalid request"}]
    end
end
