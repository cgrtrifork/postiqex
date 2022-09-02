defmodule Postiqex.Connection.Cleaner do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    send(self(), :after_init)
    {:ok, %{parent: Keyword.get(opts, :parent)}}
  end

  def handle_info(:after_init, state) do
    connection = GenServer.call(state.parent, :get_connection)
    ref = Process.monitor(connection.pid)
    {:noreply, %{state | connection: connection, ref: ref}}
  end

  # We monitor the connection to clean up after it is dead, as it can't clean after itself
  # After cleanup, we shut ourselves down
  def handle_info({:DOWN, ref, _object, _reason}, %{ref: r} = state) do
    if r == ref do
      do_cleanup(state)
      exit(:shutdown)
    else
      Logger.warn("Monitoring received DOWN message from unknown ref #{ref}")
      {:noreply, state}
    end
  end

  def do_cleanup(%{connection: c} = _state) do
    socket = Map.get(c, :socket)
    id = Map.get(c, :id)

    if socket && id do
      stop_script = Path.join([:code.priv_dir(:postiqex), "ssh-close-socket.sh"])
      {_ret, code} = System.cmd(stop_script, [socket, id])

      if code != 0 do
        Logger.warn("Couldn't close socket #{socket} with id #{id}")
      end
    end
  end
end
