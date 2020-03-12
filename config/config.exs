# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tbot,
  data_fetcher_module: Tbot.Fetcher,
  capital: 5000

# Configures the endpoint
config :tbot, TbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0+qcfEid9xQRwRgpfEMpp748kf0MBxi1nOrb1d3sF0bFhmGjO9YcfaCCg99GHPO3",
  render_errors: [view: TbotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Tbot.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
