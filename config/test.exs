use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :discovery, Discovery.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :discovery, Discovery.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "discovery_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Make password hashing less taxing on our test environment for better speeds
config :comeonein, :bcrypt_log_rounds, 4
config :comeonein, :pbkdf2_rounds, 1

config :discovery, Discovery.Mailer,
  adapter: Bamboo.TestAdapter
