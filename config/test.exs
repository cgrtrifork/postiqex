import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :postiqex, PostiqexWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "6rR9l4UKL7DpiAMzJdEm/qbjV82HpKl0Rggdn37Coq+EBhoWESK1aILXrYFHv4b1",
  server: false

# In test we don't send emails.
config :postiqex, Postiqex.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
