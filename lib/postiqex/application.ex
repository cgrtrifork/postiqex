defmodule Postiqex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Desktop.identify_default_locale(PostiqexWeb.Gettext)

    children = [
      # Start the Telemetry supervisor
      PostiqexWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Postiqex.PubSub},
      # Start the Endpoint (http/https)
      PostiqexWeb.Endpoint,
      # Start a worker by calling: Postiqex.Worker.start_link(arg)
      # {Postiqex.Worker, arg}
      {
        # After your other children
        # Starting Desktop.Windows
        Desktop.Window,
        [
          app: :postiqex,
          id: PostiqexWindow,
          menubar: PostiqexWeb.MenuBar,
          url: &PostiqexWeb.Endpoint.url/0
        ]
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Postiqex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PostiqexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
