defmodule Kundi.Application do
  @moduledoc false

  use Application

  alias Kundi.{GameRegistry, GameSupervisor, HeroRegistry, HeroSupervisor, Router}
  alias Plug.Cowboy

  @impl true
  @spec start(Application.start_type(), start_args :: term()) ::
          {:ok, pid()} | {:ok, pid(), Application.state()} | {:error, reason :: term()}
  def start(_type, _args) do
    port = "PORT" |> System.get_env("4000") |> String.to_integer()

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: GameSupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: HeroSupervisor},
      {Registry, keys: :unique, name: GameRegistry},
      {Registry, keys: :unique, name: HeroRegistry},
      Cowboy.child_spec(scheme: :http, plug: Router, options: [port: port])
    ]

    Supervisor.start_link(children, name: Kundi.Supervisor, strategy: :one_for_one)
  end
end
