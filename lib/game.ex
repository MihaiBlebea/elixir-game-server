defmodule GameServer.Game do

    defstruct id: nil, name: nil, board: nil, players_count: nil, players: []

    use GameServer.ActorBase, registry_name: :game_registry

    @spec get_players(binary) :: [pid]
    def get_players(game_id), do: get game_id, :players

    @spec get_max_players(binary) :: number
    def get_max_players(game_id), do: get game_id, :players_count

    @doc """
    #### put_player/2

    Stores a new player by id in the game struct.

    Returns the remaining number of player spaces that are not taken yet in the game

    Returns `:fail` if an error occurs

    params:
    - game_id: an id to lookup the game in the game registry
    - player_id: an id to lookup the player in the player registry

    #### example:

        iex> GameServer.Game.put_player("da60eba5-2d93-4a8d-bcf0-b622152f82a8", "12345-2d93-4a8d-bcf0-b622152f82a8")
        2

    """
    @spec put_player(binary, binary) :: :fail | integer
    def put_player(game_id, player_id) do
        already_joined =
            get_current_joined_player(game_id)
            |> Enum.filter(fn (pid)->
                pid == self()
            end)
            |> length
            |> already_joined?

        cond do
            already_joined -> :fail
            no_spaces_left? get_current_joined_player(game_id) |> length, get_max_players(game_id) -> :fail
            true ->
                GameServer.Client.register(game_id)
                push(game_id, :players, player_id)
                player_spaces_empty(get_current_joined_player(game_id) |> length, get_max_players(game_id))
        end
    end

    @spec put_name(binary, binary) :: :fail | :ok
    def put_name(game_id, name), do: put game_id, :name, name

    @spec put_max_players(binary, any) :: :fail | :ok
    def put_max_players(game_id, value), do: put game_id, :players_count, value

    @spec new(binary, number) :: binary
    def new(name, players_count) do
        id = start_link()
        id |> put_name(name)
        id |> put_max_players(players_count)

        id
    end

    defp already_joined?(0), do: false

    defp already_joined?(_), do: true

    defp no_spaces_left?(current, max_players), do: max_players == current

    defp player_spaces_empty(current, max_players), do: max_players - current

    defp get_current_joined_player(game_id) do
        GameServer.Client.lookup(game_id) |> Enum.map(fn ({pid, []})-> pid end)
    end
end
