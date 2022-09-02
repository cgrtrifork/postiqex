defmodule Postiqex.DatabaseSupervisor do
  use Supervisor

  alias Postiqex.Connection

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    host = Keyword.get(opts, :host, "localhost")

    # extend opts by passing parent pid to children
    opts = [{:parent, self()} | opts]

    maybe_connection_maker = if host != "localhost", do: [{Connection.Maker, opts}], else: []

    children = maybe_connection_maker ++ []
    Supervisor.init(children, strategy: :one_for_one)
  end

  def get_child_pid(id \\ Connection.Maker) do
    child =
      Supervisor.which_children(__MODULE__)
      |> Enum.find(&(elem(&1, 0) == id))

    if child do
      elem(child, 1)
    end
  end

  def get_connection() do
    child =
      Supervisor.which_children(__MODULE__)
      |> Enum.find(&(elem(&1, 0) == Connection.Maker))

    child_pid = if child, do: elem(child, 1)
    GenServer.call(child_pid, :get_connection)
  end

  def handle_call({:get_child_pid, id}, _from, state) do
    {:reply, get_child_pid(id), state}
  end

  def handle_call(:get_connection, _from, state) do
    {:reply, get_connection(), state}
  end

  def handle_info({:EXIT, pid, :normal}, state) do
    cleaner_pid = get_child_pid(Connection.Cleaner)
    # we ignore the cleaner
    if pid != cleaner_pid do
      exit(:normal)
    else
      {:noreply, state}
    end
  end

  def handle_info(other, state) do
    IO.inspect(other, label: "RECEIVED OTHER INFO:")
    IO.inspect(state, label: "with state:")
    {:noreply, state}
  end
end
