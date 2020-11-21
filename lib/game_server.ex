defmodule GameServer do
    use Application

    @spec start(any, any) :: {:error, any} | {:ok, pid}
    def start(_type, _args) do
        children = [
            Plug.Cowboy.child_spec(
                scheme: :http,
                plug: GameServer.Router,
                options: [
                    dispatch: dispatch(),
                    port: 4000
                ]
            ),
            Registry.child_spec(
                keys: :duplicate,
                name: :socket_conn_registry
            ),
            {
                Registry, [keys: :unique, name: :game_registry]
            },
        ]

        Supervisor.start_link(children, strategy: :one_for_one)
    end

    defp dispatch do
        [
            {:_,
                [
                    {"/ws/[...]", GameServer.SocketHandler, []},
                    {:_, Plug.Cowboy.Handler, {GameServer.Router, []}}
                ]
            }
        ]
    end
end
