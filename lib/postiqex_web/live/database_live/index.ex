defmodule PostiqexWeb.DatabaseLive.Index do
  use PostiqexWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    IO.inspect(params)
    IO.inspect(session)
    IO.inspect(socket)
    {:ok, socket}
  end
end
