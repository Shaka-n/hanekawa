defmodule Hanekawa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HanekawaWeb.Telemetry,
      # Start the Ecto repository
      Hanekawa.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Hanekawa.PubSub},
      # Start Finch
      {Finch, name: Hanekawa.Finch},
      # Start the Endpoint (http/https)
      HanekawaWeb.Endpoint,
      # Start a worker by calling: Hanekawa.Worker.start_link(arg)
      # {Hanekawa.Worker, arg}
      Hanekawa.ConsumerSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hanekawa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HanekawaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
