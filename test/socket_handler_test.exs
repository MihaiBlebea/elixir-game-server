defmodule SocketHandlerTest do
    use ExUnit.Case

    defp transform_response({:text, message}) do
        message
        |> Poison.decode!
        |> GameServer.SocketHandler.to_atoms
        |> GameServer.SocketHandler.validate_payload
    end

    defp build_request(body) do
        {:text, body |> Poison.encode!}
    end

    defp socket_connect(), do: Socket.Web.connect! { "localhost", 4000 }, path: "/ws"

    defp socket_send(socket, request) do
        socket |> Socket.Web.send!(build_request(request))

        socket
    end

    defp socket_receive(socket), do: socket |> Socket.Web.recv! |> transform_response

    test "can create a game" do
        request = %{
            type: "game_create",
            player_count: 2,
            game_name: "abcd"
        }

        message = socket_connect |> socket_send(request) |> socket_receive

        assert message.type == :game_created
        assert is_binary message.game_id
        assert message.max_players == 2
    end

    test "can join a game" do
        create_req = %{
            type: "game_create",
            player_count: 2,
            game_name: "abcd"
        }

        conn = socket_connect

        create_resp = conn |> socket_send(create_req) |> socket_receive

        join_req = %{
            type: "game_join",
            game_id: create_resp.game_id,
            player_name: "Mihai"
        }

        join_resp = conn |> socket_send(join_req) |> socket_receive

        assert join_resp.type == :game_joined
        assert is_binary join_resp.game_id
        assert join_resp.spaces_left == 1
    end

    test "can not join twice from the same connection" do
        create_req = %{
            type: "game_create",
            player_count: 2,
            game_name: "abcd"
        }

        conn = socket_connect

        create_resp = conn |> socket_send(create_req) |> socket_receive

        join_req = %{
            type: "game_join",
            game_id: create_resp.game_id,
            player_name: "Mihai"
        }

        conn |> socket_send(join_req) |> socket_receive

        join_resp = conn |> socket_send(join_req) |> socket_receive

        assert join_resp.type == :game_error
        assert join_resp.message == "could not add player to the game"
    end

    test "can not join after all spaces are full" do
        create_req = %{
            type: "game_create",
            player_count: 1,
            game_name: "abcd"
        }

        conn = socket_connect

        create_resp = conn |> socket_send(create_req) |> socket_receive

        join_req = %{
            type: "game_join",
            game_id: create_resp.game_id,
            player_name: "Mihai"
        }

        conn |> socket_send(join_req) |> socket_receive

        pid = Task.async fn ()-> conn |> socket_send(join_req) |> socket_receive end

        resp = Task.await pid

        assert resp.type == :game_error
        assert resp.message == "could not add player to the game"
    end
end
