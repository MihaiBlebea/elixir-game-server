defmodule GameServer.Router do
    use Plug.Router

    require Logger

    # plug CORSPlug, origin: ["http://localhost:8080"]
    plug Plug.Logger
    plug Plug.Static,
        at: "/",
        from: "./public"
    plug :match
    plug :dispatch

    get "/" do
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, File.read!("./public/index.html"))
    end

    get "/board" do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(GameServer.Board.build(11)))
    end

    post "/game" do
        game_id = GameServer.Game.start_link()
        # board = GameServer.Game.get(game_id, :board)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(%{code: game_id}))
    end

    match _ do
        send_resp(conn, 404, "Route not found")
    end
end
