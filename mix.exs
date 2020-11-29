defmodule GameServer.MixProject do
    use Mix.Project

    def project do
        [
            app: :game_server,
            version: "0.1.0",
            elixir: "~> 1.10",
            elixirc_paths: elixirc_paths(Mix.env),
            start_permanent: Mix.env() == :prod,
            deps: deps()
        ]
    end

    # Run "mix help compile.app" to learn about applications.
    def application do
        [
            extra_applications: [:logger],
            mod: {GameServer, []}
        ]
    end

    defp elixirc_paths(:test), do: ["lib", "web", "test"]
    defp elixirc_paths(_), do: ["lib", "web"]

    defp deps do
        [
            {:plug_cowboy, "~> 2.0"},
            # {:json, "~> 1.2"},
            {:poison, "~> 3.1"},
            {:uuid, "~> 1.1"},
            {:ex_doc, "~> 0.22", only: :dev, runtime: false},
            {:socket, "~> 0.3.13", only: [:dev, :test], runtime: false}
        ]
    end
end
