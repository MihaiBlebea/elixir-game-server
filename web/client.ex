defmodule GameServer.Client do

    use GenServer

    @table_name :clients_table

    @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
    def start_link(_) do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
    end

    @spec init(any) :: {:ok, any}
    def init(arg) do
        :ets.new(@table_name, [
            :set,
            :public,
            :named_table,
            {:read_concurrency, true},
            {:write_concurrency, true}
        ])

        {:ok, arg}
    end

    @spec get(any) :: any
    def get(key) do
        case :ets.lookup(@table_name, key) do
            [] -> nil
            [{_key, value}] -> value
        end
    end

    @spec put(any, any) :: true
    def put(key, value), do: :ets.insert(@table_name, {key, value})

    @spec create_id :: binary
    def create_id() do
        UUID.uuid4()
    end
end
