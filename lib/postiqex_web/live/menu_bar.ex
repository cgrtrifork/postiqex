defmodule PostiqexWeb.MenuBar do
  use Desktop.Menu

  alias Desktop.Window
  alias PostiqexWeb.Router.Helpers, as: Routes

  def mount(menu) do
    {:ok, assign(menu, values: [1, 2, 3])}
  end

  def handle_info(params, menu) do
    IO.inspect(params)
    IO.inspect(menu)

    {:noreply, menu}
  end

  def handle_event("quit", menu) do
    Window.quit()
    {:noreply, menu}
  end

  def handle_event("browser", menu) do
    Window.prepare_url(PostiqexWeb.Endpoint.url())
    |> :wx_misc.launchDefaultBrowser()

    {:noreply, menu}
  end

  def handle_event("notification", menu) do
    Window.show_notification(PostiqexWindow, "Sample Elixir Desktop App!",
      callback: &notification_event/1
    )

    {:noreply, menu}
  end

  def handle_event("dashboard", menu) do
    Desktop.Window.start_link(
      app: :postiqex,
      id: PostiqexDashboard,
      url: fn -> Routes.live_dashboard_url(PostiqexWeb.Endpoint, :home) end
    )

    {:ok, menu}
  end

  def notification_event(action) do
    Window.show_notification(PostiqexWindow, "You did '#{inspect(action)}' me!",
      id: :click,
      type: :warning
    )
  end
end
