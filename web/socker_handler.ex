defmodule GameServer.SocketHandler do

    use GameServer.SocketHandlerBase

    alias GameServer.Game

    defp handle_event_type(%{"type" => "game_create", "players_count" => players_count}) do
        game_id = GameServer.Game.start_link
        GameServer.Game.generate_board game_id
        GameServer.Game.put_players_count game_id, players_count

        %{ type: "game_created", game_id: game_id, max_players: players_count } |> Poison.encode!
    end

    defp handle_event_type(%{"type" => "game_join", "game_id" => game_id}) do
        case Game.player_spaces_left game_id do
            0 -> %{ type: "game_error", message: "no spaces left" } |> Poison.encode!
            1 ->
                # Send the board and start the game
                Game.put_player(game_id, self())
                board = Game.get_board(game_id)
                resp = %{ type: "game_joined", board: board, spaces_left: 0, game_id: game_id} |> Poison.encode!
                resp |> send_to_all_players(game_id)

                resp

            spaces_left ->
                Game.put_player(game_id, self())

                resp = %{ type: "game_joined", spaces_left: spaces_left - 1 } |> Poison.encode!
                resp |> send_to_all_players(game_id)

                resp
        end
    end

    # defp handle_event_type(%{"type" => "game_move", "game_id" => game_id, "direction" => direction}) do
    #     resp = %{ type: "game_moved", direction: direction } |> Poison.encode!
    #     resp |> send_to_all_players(game_id)

    #     resp
    # end

    defp handle_event_type(%{"type" => "game_move", "game_id" => game_id, "x" => x, "y" => y, "move_x" => move_x}) do
        resp = %{ type: "game_moved", x: x, y: y, move_x: move_x} |> Poison.encode!

        resp |> send_to_all_players(game_id)

        resp
    end

    defp handle_event_type(%{"type" => "game_move", "game_id" => game_id, "x" => x, "y" => y, "move_y" => move_y}) do
        resp = %{ type: "game_moved", x: x, y: y, move_y: move_y} |> Poison.encode!

        resp |> send_to_all_players(game_id)

        resp
    end

    defp handle_event_type(_) do
        %{ type: "game_error", message: "invalid request" } |> Poison.encode!
    end

    defp send_to_all_players(response, game_id) do
        Game.get_players(game_id)
        |> Enum.map(fn (pid)->
            if pid != self() do
                Process.send(pid, response, [])
            end
        end)
    end
end
