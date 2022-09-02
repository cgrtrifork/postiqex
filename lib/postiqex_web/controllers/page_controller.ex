defmodule PostiqexWeb.PageController do
  use PostiqexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
