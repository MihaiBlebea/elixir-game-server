defmodule GameServer do
    use Application

    alias GameServer.Client

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
            {
                Registry, [keys: :unique, name: :game_registry]
            },
            {
                Registry, [keys: :unique, name: :player_registry]
            },
            {
                Registry, [keys: :duplicate, name: Client.get_registry_key]
            }
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
