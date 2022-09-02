defmodule Postiqex.Connection.Maker do
  use GenServer, restart: :transient

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  @spec init(keyword) :: {:code, pos_integer} | {:error, Jason.DecodeError.t()} | {:ok, any}
  def init(opts) do
    user = Keyword.get(opts, :user)
    host = Keyword.get(opts, :host)
    pkey = Keyword.get(opts, :pkey)
    # database = Keyword.get(opts, :database)
    # db_user = Keyword.get(opts, :db_user)
    # db_pwd = Keyword.get(opts, :db_pwd)
    db_port = Keyword.get(opts, :db_port)

    ssh_script = Path.join([:code.priv_dir(:postiqex), "ssh-port-forward.sh"])
    {ret, code} = System.cmd(ssh_script, [user, host, db_port, pkey])

    with {:code, 0} <- {:code, code},
         {:ok, %{"socket" => s, "id" => id}} <- Jason.decode(ret) do
      {:ok, %{socket: s, id: id}}
    else
      {:code, 0} = err -> {:error, err}
      err -> err
    end
  end

  @impl true
  def handle_call(:get_connection, _from, state) do
    {:reply, %{state | pid: self()}, state}
  end
end
