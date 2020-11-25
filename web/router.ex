defmodule GameServer.Router do
    use Plug.Router

    require Logger

    # plug CORSPlug, origin: ["http://localhost:8080"]
    plug Plug.Logger
    plug Plug.Static,
        at: "/",
        from: "./public"
    plug Plug.Static,
        at: "/",
        from: "./doc"
    plug :match
    plug :dispatch

    get "/" do
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, File.read!("./public/index.html"))
    end

    get "/docs" do
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, File.read!("./doc/index.html"))
    end

    # get "/board" do
    #     conn
    #     |> put_resp_content_type("application/json")
    #     |> send_resp(200, Poison.encode!(GameServer.Board.build(11)))
    # end

    # post "/game" do
    #     game_id = GameServer.Game.start_link()

    #     spawn fn ()-> GameServer.Game.run_game_loop(game_id) end

    #     conn
    #     |> put_resp_content_type("application/json")
    #     |> send_resp(200, Poison.encode!(%{code: game_id}))
    # end

    match _ do
        send_resp(conn, 404, "Route not found")
    end
end
