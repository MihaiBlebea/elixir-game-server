defmodule GameServer.IDefineBoard do
    @callback build(number) :: map

    @callback build_level(map) :: map

    @callback get_empty_boxes(map) :: [map]

    @callback get_box(map, number, number) :: Box.t() | nil

    @callback add_entity(map, number, number, atom) :: map
end
