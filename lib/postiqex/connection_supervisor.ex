defmodule Postiqex.ConnectionSupervisor do
  use DynamicSupervisor, restart: :transient

  alias Postiqex.DatabaseSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_child(options \\ []) do
    DynamicSupervisor.start_child(__MODULE__, {DatabaseSupervisor, options})
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one
      # extra_arguments: [arg]
    )
  end
end
