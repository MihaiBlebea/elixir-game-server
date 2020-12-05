defmodule GameServer.Snake do

    use GameServer.Player

    @spec init :: map
    def init() do
        %{score: 0, body: [build_body_part(0,1), build_body_part(0,2), build_body_part(0, 3)]}
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

    defp get_head([ head | _tail ]), do: head

    def get_body(player_id), do: get player_id, :body

    @spec move(binary) :: :fail | :ok
    def move(player_id) do
        body = get(player_id, :body)
        tailles_body = body |> remove_tail
        %{x: head_x, y: head_y} = get_head body
        %{x: dir_x, y: dir_y} = get_direction body
        new_head = build_body_part(head_x + dir_x, head_y + dir_y)

        put player_id, :body, [new_head] ++ tailles_body
    end

    @spec move(binary, integer, integer) :: :fail | :ok
    def move(player_id, dir_x, dir_y) do
        body = get(player_id, :body)
        tailles_body = body |> remove_tail
        %{x: head_x, y: head_y} = get_head body
        new_head = build_body_part(head_x + dir_x, head_y + dir_y)

        put player_id, :body, [new_head] ++ tailles_body
    end
end
