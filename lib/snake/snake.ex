defmodule GameServer.Snake do

    use GameServer.Player

    @spec init :: map
    def init() do
        %{score: 0, body: [build_body_part(10,10), build_body_part(10, 11), build_body_part(10, 12)]}
    end

    defp remove_tail(body), do: body |> List.pop_at(-1) |> Tuple.to_list |> Enum.at(1)

    defp build_body_part(x, y), do: %{x: x, y: y}

    defp get_direction(body) do
        (length(body) < 2) |> has_less_then_two_segments(body)
    end

    defp has_less_then_two_segments(true, _body), do: :fail

    defp has_less_then_two_segments(false, body) do
        %{x: head_x, y: head_y} = body |> get_head
        %{x: body_x, y: body_y} = body |> Enum.at(1)

        %{x: head_x - body_x, y: head_y - body_y}
    end

    @spec get_head(list) :: map
    def get_head([ head | _tail ]), do: head

    @spec get_body(binary) :: list
    def get_body(player_id), do: get player_id, :body

    defp get_last_segment(player_id), do: player_id |> get_body |> List.last

    @spec move(binary) :: :fail | :ok
    def move(player_id) do
        body = get(player_id, :body)
        %{x: dir_x, y: dir_y} = get_direction body

        move(player_id, dir_x, dir_y)
    end

    @spec move(binary, integer, integer) :: :fail | :ok
    def move(player_id, dir_x, dir_y) do
        body = get(player_id, :body)
        tailles_body = body |> remove_tail
        %{x: head_x, y: head_y} = get_head body
        new_head = build_body_part(head_x + dir_x, head_y + dir_y)

        put player_id, :body, [new_head] ++ tailles_body
    end

    @spec eat(binary) :: :fail | :ok
    def eat(player_id), do: player_id |> push(:body, get_last_segment(player_id))
end
