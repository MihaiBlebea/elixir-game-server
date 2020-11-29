defmodule GameServer.Snake do

    defstruct player_id: nil, player_name: nil, body: []

    @spec new(binary, binary) :: %GameServer.Snake{}
    def new(player_id, player_name) do
        body = Enum.map(1..3, fn (index)-> build_body_part(0, index) end)

        %__MODULE__{player_id: player_id, player_name: player_name, body: body}
    end

    defp remove_tail(body), do: body |> List.pop_at(-1) |> Tuple.to_list |> Enum.at(1)

    defp build_body_part(x, y) do
        %{x: x, y: y}
    end

    defp get_direction(snake) do
        case length(snake.body) < 2 do
            true -> :fail
            false ->
                %{x: head_x, y: head_y} = snake.body |> get_head
                %{x: body_x, y: body_y} = snake.body |> Enum.at(1)

                %{x: head_x - body_x, y: head_y - body_y}
        end
    end

    defp get_head([ head | _tail ]), do: head

    defp get_body(%__MODULE__{body: body}), do: body

    @spec move(%GameServer.Snake{}) :: %GameServer.Snake{}
    def move(snake) do
        tailles_body = get_body(snake) |> remove_tail |> IO.inspect
        %{x: head_x, y: head_y} = get_head snake.body
        %{x: dir_x, y: dir_y} = get_direction snake

        new_head = build_body_part(head_x + dir_x, head_y + dir_y)
        Map.put(snake, :body, [new_head] ++ tailles_body)
    end
end
