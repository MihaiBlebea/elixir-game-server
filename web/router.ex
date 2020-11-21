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
        |> send_resp(200, JSON.encode!(GameServer.Board.build(5)))
    end

    match _ do
        send_resp(conn, 404, "Route not found")
    end
end
