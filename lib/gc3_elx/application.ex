defmodule Gc3Elx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Gc3ElxWeb.Telemetry,
      Gc3Elx.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:gc3_elx, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:gc3_elx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Gc3Elx.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Gc3Elx.Finch},
      # Start a worker by calling: Gc3Elx.Worker.start_link(arg)
      # {Gc3Elx.Worker, arg},
      # Start to serve requests, typically the last entry
      Gc3ElxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gc3Elx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Gc3ElxWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
