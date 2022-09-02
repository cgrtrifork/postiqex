defmodule Postiqex.Repo do
  use Ecto.Repo,
    otp_app: :postiqex,
    adapter: Ecto.Adapters.Postgres
end
